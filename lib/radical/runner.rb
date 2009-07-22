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
        opts.on("-x", "--no-log", "Turn off logging") do
          options['no-log'] = true
        end
        opts.on("-u", "--username=USER", "Specify username") do |u|
          options['username'] = u
        end
        opts.on("-p", "--password=PWD", "Specify password") do |p|
          options['password'] = p
        end
        opts.on("-b", "--base-uri=URI", "Specify base-uri") do |b|
          options['base_uri'] = b
        end
        opts.on("-d", "--data-dir=DIR", "Specify data directory") do |d|
          options['data_dir'] = d
        end
      end
      parser.parse!(args)
      if options['config'].nil?
        puts parser.banner
        raise "Configuration file is required"
      end

      if options.delete('no-log')
        @logger = nil
      else
        @logger = Logger.new(options.delete('log') || $stderr)
      end

      config = YAML.load_file(options.delete('config'))
      config.merge!(options)
      Radical.setup(config)
      @data_dir = File.expand_path(config['data_dir'])  if config['data_dir']

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
              log :info, "File '#{filename}' has changed; putting #{type} #{item_id}."
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

        log :info, "Syncing #{type}s"
        Fetcher.get(type, :all).each do |item|
          log :info, "- #{item.id}"
          item.to_files(dir, :symlinks => true).each do |filename|
            @items[type][item.id] << [filename, File.mtime(filename)]
          end
        end
      end
    end

    private
      def log(level, message)
        @logger.send(level, message)   if @logger
      end
  end
end
