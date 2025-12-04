# frozen_string_literal: true

require_relative "fcm/version"
require "debug"
require "segment"
module Fcm
  def self.run
    based = ENV["BASED"]
    file = ARGV.last
    return if based.nil? || file.nil?
    
    data = read_file(file) if file.split(".").last == "txt"
    return if data.nil? || data.empty?

    segments = create_objects(data)
    return if segments.nil? || segments.empty?

    order_segments = sorted_segments(segments)
    group_segments(order_segments, based)
  end

  def self.read_file(file)
    filedata = File.readlines(file)
    filedata.select { |l| l.include?("SEGMENT") }
  end

  def self.create_objects(data)
    segments = []
    data.each do |line|
      segments << Segment.new(line)
    rescue Error => e
      puts "Error with line: #{e}"
    end
    segments
  end

  def self.sorted_segments(segments)
    segments.sort_by { |s| s.departure_time }
  end

  def self.group_segments(segments, based)
    initial_segments = segments.select { |s| s.from == based }
    initial_segments.each do |previous_step|
      travel = [previous_step]
      loop do
        next_step = calculate_next_step(segments, previous_step)
        travel << next_step if next_step
        break if next_step.nil? || next_step.to == based
        previous_step = next_step
      end
      write_travel(travel)
    end
  end

  def self.calculate_next_step(segments, previous_step)
    segments.detect do |step| 
      previous_step.to == step.from && previous_step.arrival_time <= step.departure_time
    end
  end

  def self.write_travel(travel)
    puts "TRIP TO #{travel.first.to}"
    travel.each do |segment|
      puts segment.write_output
    end
  end
end

Fcm.run
