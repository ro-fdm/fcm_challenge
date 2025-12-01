# frozen_string_literal: true

require_relative "fcm/version"
require "debug"
require "segment"
module Fcm
  def self.run
    file = ARGV.last
    data = read_file(file) if file && file.split(".").last == "txt"
    return if data.nil? || data.empty?

    create_objects(data)
  end

  def self.read_file(file)
    filedata = File.readlines(file)
    filedata.select { |l| l.include?("SEGMENT") }
  end

  def self.create_objects(data)
    @segments = []
    data.each do |line|
      @segments << Segment.new(line)
    rescue Error => e
      puts "Error with line: #{e}"
    end
    @segments
  end
end

Fcm.run
