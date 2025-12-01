require "error"
require "date"

class Segment
  attr_accessor :departure_place, :destination, :arrival_time, 
                :departure_time, :transport, :accomodation

  def initialize(line)
    read_line(line)
  #rescue Error => e
   # puts "Error with line: #{line}"
  end


  private

  # examples:
  # ["SEGMENT:", "Flight", "SVQ", "2023-03-02", "06:40", "->", "BCN", "09:10"]
  # ["SEGMENT:", "Hotel", "BCN", "2023-01-05", "->", "2023-01-10"]
  def read_line(line)
    data = line.split(" ")
    if data.size == 8
      write_ticket(data)
    elsif data.size == 6
      write_accomodation(data)
    else
      raise Error.new("Problem with size in: #{line}")
    end
  end

  def write_ticket(data)
    @transport = data[1]
    @departure_place = data[2]
    @departure_time = calculate_date(date: data[3], time: data[4])
    @destination = data[6]
    @arrival_time = calculate_date(date: data[3], time: data[7])
  rescue Date::Error => e
     raise Error.new("Problem with date in: #{data}")
  end

  def write_accomodation(data)
    @accomodation = data[1]
    @destination = data[2]
    @departure_time = calculate_date(date: data[5])
    @arrival_time = calculate_date(date: data[3])
  rescue Date::Error => e
    raise Error.new("Problem with date in: #{data}")
  end

  def calculate_date(date:, time: "00:00")
    date_data = date.split("-")
    time_data = time.split(":")
    DateTime.new(date_data[0].to_f, 
                 date_data[1].to_f,
                 date_data[2].to_f,
                 time_data[0].to_f,
                 time_data[1].to_f)
  end
end