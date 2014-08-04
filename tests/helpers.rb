require "test/unit"
require "fileutils"

DIRECTORY_ROOT = "/tmp/"

class TestHelper

  def self::GetTestDirectory
    random = "vfy_test_" + rand(2**128).to_s
    path = File.join(DIRECTORY_ROOT, random)
    Dir.mkdir(path)
    return path
  end

  def self::DeleteTestDirectory(path)
    FileUtils.rm_rf(path)
  end

  def self::FillContents(dir, contents)
    contents.each do |name, info|
      case info[:type]
      when 'file'
        File.write(File.join(dir, name), info[:contents])
      when 'directory'
        path = File.join(dir, name)
        Dir.mkdir(path)
        self::FillContents(path, info[:contents])
      when 'symlink'
        throw "Symlink filling is not implemented yet!"
      when 'mount'
        throw "Mount filling is not implemented yet!"
      end
    end
  end

  # FIXME: Check exit status, do this better.

  def self::RunVerification(options)
    command = ["ruby", "tests/run-vfy-with-coverage.rb"] + options + ["-m"]
    result = {}
    IO.popen(command) do |p|
      output_lines = p.readlines
      # Last line is SimpleCov output. Second last is the one we want.
      /SUMMARY: items:(\d+), diff:(\d+), similar:(\d+), diffpct:(.*), skip:(\d+), err:(\d+)/ =~ output_lines[-2]
      result = {
        items_processed: $1.to_i,
        differences: $2.to_i,
        similarities: $3.to_i,
        skipped: $5.to_i,
        errors: $6.to_i
      }
    end
    return result
  end

end
