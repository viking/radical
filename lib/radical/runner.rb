require 'yaml'
require 'optparse'

module Radical
  class Runner
    def initialize(args = ARGV)
      OptionParser.new do |opts|
        opts.banner = "Usage: runner.rb -c <file>"
        opts.on("-c", "--config=FILE", "Specify configuration file") do |c|
          config = YAML.load_file(c)
          Radical.setup(config)
        end
      end.parse!(args)
    end
  end
end
