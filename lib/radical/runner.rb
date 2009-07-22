require 'yaml'
require 'optparse'
require 'fileutils'
require 'logger'

module Radical
  class Runner
    DATA_DIR = File.expand_path(File.dirname(__FILE__) + "/../../data")

    def initialize(args = ARGV)
      options = {}
      parser = OptionParser.new do |opts|
        opts.banner = "Usage: runner.rb -c <file>"
        opts.on("-c", "--config=FILE", "Specify configuration file") do |c|
          options['config'] = c
        end
        opts.on("-l", "--log=FILE", "Specify log file (default is STDERR)") do |l|
          options['log'] = l
        end
      end
      parser.parse!(args)
      if options['config'].nil?
        puts parser.banner
        raise "Configuration file is required"
      end

      # setup Radical from config file
      config = YAML.load_file(options['config'])
      Radical.setup(config)
      @data_dir = File.expand_path(config['data_dir'])  if config['data_dir']
      @log = Logger.new(options['log'] || $stderr)

      @data_dir ||= DATA_DIR
      @items = %w{page layout snippet}.inject({}) do |h, t|
        h[t] = Hash.new { |h, k| h[k] = [] }; h
      end
      sync
    end

    def check
      # check timestamps
      @items.each_key do |type|
        dir = "#{@data_dir}/#{type}s"
        @items[type].each_pair do |item_id, timestamps|
          timestamps.each_index do |i|
            filename, old_mtime = timestamps[i]
            new_mtime = File.mtime(filename)
            if new_mtime > old_mtime
              @log.info "File '#{filename}' has changed; putting #{type} #{item_id}."
              klass = Models.const_get(type.capitalize)
              item = klass.from_files(dir, item_id)
              Fetcher.put(item)
              @items[type][item_id][i][1] = new_mtime
              break
            end
          end
        end
      end
    end

    def sync
      @items.each_key do |type|
        dir = "#{@data_dir}/#{type}s"
        FileUtils.mkdir(dir)  if !File.exist?(dir)

        @log.info "Syncing #{type}s"
        Fetcher.get(type, :all).each do |item|
          @log.info "- #{item.id}"
          item.to_files(dir).each do |filename|
            @items[type][item.id] << [filename, File.mtime(filename)]
          end
        end
      end
    end
  end
end
