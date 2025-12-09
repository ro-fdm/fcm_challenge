# frozen_string_literal: true

require_relative "fcm/version"
require "debug"
require "segment"
module Fcm
  def self.run
    based = ENV.fetch("BASED", nil)
    file = ARGV.last
    return if values_wrong(based, file)

    data = read_file(file)
    return if data_wrong(data)

    segments = create_objects(data)
    return if segments_wrong(segments)

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
    segments.sort_by(&:departure_time)
  end

  # rubocop:disable Metrics/MethodLength
  def self.group_segments(segments, based)
    initial_segments(segments, based).each do |previous_step|
      segments.delete(previous_step)
      travel = [previous_step]
      segments.each do |next_step|
        break if next_step.from == based

        if check_step?(previous_step, next_step)
          travel << next_step
          previous_step = next_step
        end
      end
      segments -= travel
      write_travel(travel)
    end
  end
  # rubocop:enable Metrics/MethodLength

  def self.check_step?(previous_step, next_step)
    previous_step.to == next_step.from
  end

  def self.initial_segments(segments, based)
    segments.select { |s| s.from == based }
  end

  def self.write_travel(travel)
    destination = calculate_destination(travel)

    puts "TRIP to #{destination}"
    travel.each do |segment|
      puts segment.write_output
    end
  end

  def self.calculate_destination(travel)
    accomodation = travel.detect(&:accomodation)
    return accomodation.to if accomodation

    return travel[1].to if travel[1] && travel[1].departure_time <= travel[0].arrival_time + 1

    travel[0].to
  end

  def self.values_wrong(based, file)
    value = based.nil? || file.nil? || file.split(".").last != "txt"
    print_error({ based: based, file: file }) if value
    value
  end

  def self.data_wrong(data)
    value = data.nil? || data.empty?
    print_error({ data: "not right data in the file" }) if value
    value
  end

  def self.segments_wrong(segments)
    value = segments.nil? || segments.empty?
    print_error({ segments: "no created segments" }) if value
    value
  end

  # rubocop:disable Metrics/MethodLength
  def self.print_error(object)
    keys = object.keys
    msg = if keys.include?(:based) && object[:based].nil?
            "not passed BASED environment variable"
          elsif keys.include?(:file) && object[:file].nil?
            "not passed file to read"
          elsif keys.include?(:file) && object[:file].split(".").last != "txt"
            "file is not a txt"
          else
            object[keys.first]
          end

    puts "Error: #{msg}"
  end
  # rubocop:enable Metrics/MethodLength
end

Fcm.run
