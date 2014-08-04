require "fileutils"
FileUtils.rm_rf("./coverage")
require_relative "tests.rb"
