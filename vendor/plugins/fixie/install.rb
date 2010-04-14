require 'pathname'
require 'fileutils'

fixie_dir = Pathname.new(File.dirname(__FILE__)).join('..', '..', '..', 'test', 'fixie')
if !File.exist?(fixie_dir)
  puts "Creating test/fixie directory"
  FileUtils.mkdir(fixie_dir)
end
