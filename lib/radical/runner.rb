require 'yaml'
require 'optparse'
require 'fileutils'

module Radical
  class Runner
    DATA_DIR = File.expand_path(File.dirname(__FILE__) + "/../../data")

    def initialize(args = ARGV)
      OptionParser.new do |opts|
        opts.banner = "Usage: runner.rb -c <file>"
        opts.on("-c", "--config=FILE", "Specify configuration file") do |c|
          config = YAML.load_file(c)
          Radical.setup(config)
          @data_dir = File.expand_path(config['data_dir'])  if config['data_dir']
        end
      end.parse!(args)

      @pages = Hash.new { |h, k| h[k] = [] }
      @data_dir ||= DATA_DIR
      @pages_dir = "#{@data_dir}/pages"
      sync
    end

    def check
      # check timestamps
      @pages.each_pair do |page_id, timestamps|
        timestamps.each_index do |i|
          filename, old_mtime = timestamps[i]
          new_mtime = File.mtime(filename)
          if new_mtime > old_mtime
            page = Models::Page.from_files(@pages_dir, page_id)
            Fetcher.put_page(page)
            @pages[page_id][i][1] = new_mtime
            break
          end
        end
      end
    end

    def sync
      FileUtils.mkdir(@pages_dir)  if !File.exist?(@pages_dir)

      Fetcher.get_pages.each do |page|
        page.to_files(@pages_dir).each do |filename|
          @pages[page.id] << [filename, File.mtime(filename)]
        end
      end
    end
  end
end
