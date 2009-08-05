require 'fileutils'

desc 'Remove data files'
task :clean do
  Dir[File.dirname(__FILE__) + "/data/*"].each do |dir|
    FileUtils.rm_rf dir, :verbose => true
  end
end
