# frozen_string_literal: true

require_relative "fcm/version"
require "debug"
require "segment"
module Fcm
  # rubocop:disable Metrics/CyclomaticComplexity
  def self.run
    based = ENV.fetch("BASED", nil)
    file = ARGV.last
    if based.nil? || file.nil? || file.split(".").last != "txt"
      print_error(based, file)
      return
    end

    data = read_file(file)
    if data.nil? || data.empty?
      print_error(based, file, "not right data in the file")
      return
    end

    segments = create_objects(data)
    if segments.nil? || segments.empty?
      print_error(based, file, "no created segments")
      return
    end

    order_segments = sorted_segments(segments)
    group_segments(order_segments, based)
  end
  # rubocop:enable Metrics/CyclomaticComplexity

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

  def self.group_segments(segments, based)
    initial_segments(segments, based).each do |previous_step|
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

  def self.initial_segments(segments, based)
    segments.select { |s| s.from == based }
  end

  def self.calculate_next_step(segments, previous_step)
    segments.detect do |step|
      previous_step.to == step.from && previous_step.arrival_time <= step.departure_time
    end
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

    return travel[1].to if travel[1] && travel[0].arrival_time <= travel[1].departure_time + 1

    travel[0].to
  end

  def self.print_error(based, file, message = nil)
    error = if based.nil?
              "not passed BASED environment variable"
            elsif file.nil?
              "not passed file to read"
            elsif file.split(".").last != "txt"
              "file is not a txt"
            else
              message
            end

    puts "Error: #{error}"
  end
end

Fcm.run
