require 'simplecov'
SimpleCov.command_name rand(2**128).to_s
SimpleCov.start
puts "INFO: Required simplecov"

require_relative '../vfy.rb'
