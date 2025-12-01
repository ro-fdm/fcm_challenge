# frozen_string_literal: true

require_relative "fcm/version"
require "debug"
module Fcm
  def self.run
    file = ARGV.last
    read_file(file) if file && file.split(".").last == "txt"
  end

  def self.read_file(file)
    filedata = File.readlines(file)
    filedata.select { |l| l.include?("SEGMENT") }
  end

  class Error < StandardError; end
  # Your code goes here...
end

Fcm.run
