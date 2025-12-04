# frozen_string_literal: true

require "error"
require "date"

class Segment
  attr_accessor :from, :to, :arrival_time,
                :departure_time, :transport, :accomodation

  def initialize(line)
    create_from_line(line)
  end

  def write_output
    if transport
      output_transport
    elsif accomodation
      output_accomodation
    else
      puts "Dont recognise type of segment"
    end
  end

  private

  # examples:
  # ["SEGMENT:", "Flight", "SVQ", "2023-03-02", "06:40", "->", "BCN", "09:10"]
  # ["SEGMENT:", "Hotel", "BCN", "2023-01-05", "->", "2023-01-10"]
  def create_from_line(line)
    data = line.split
    if data.size == 8
      write_ticket(data)
    elsif data.size == 6
      write_accomodation(data)
    else
      raise Error, "Problem with size in: #{line}"
    end
  end

  def write_ticket(data)
    @transport = data[1]
    @from = data[2]
    @departure_time = calculate_date(date: data[3], time: data[4])
    @to = data[6]
    @arrival_time = calculate_date(date: data[3], time: data[7])
  rescue Date::Error
    raise Error, "Problem with date in: #{data}"
  end

  def write_accomodation(data)
    @accomodation = data[1]
    @from = data[2]
    @to = data[2]
    @arrival_time = calculate_date(date: data[5], time: "00:00")
    @departure_time = calculate_date(date: data[3], time: "23:59")
  rescue Date::Error
    raise Error, "Problem with date in: #{data}"
  end

  def output_transport
    "#{transport} from #{from} to #{to} at #{departure_time} to #{arrival_time}"
  end

  def output_accomodation
    "#{accomodation} at #{from} on #{departure_time} to #{arrival_time}"
  end

  def calculate_date(date:, time:)
    date_data = date.split("-")
    time_data = time.split(":")
    DateTime.new(date_data[0].to_f,
                 date_data[1].to_f,
                 date_data[2].to_f,
                 time_data[0].to_f,
                 time_data[1].to_f)
  end
end
