# frozen_string_literal: true

require "date"

module DateParse
  def calculate_date(date:, time:)
    date_data = date.split("-")
    time_data = time.split(":")
    DateTime.new(date_data[0].to_f,
                 date_data[1].to_f,
                 date_data[2].to_f,
                 time_data[0].to_f,
                 time_data[1].to_f)
  end

  def date_time_parse(datetime)
    datetime.strftime("%Y-%m-%d %H:%M")
  end

  def date_parse(datetime)
    datetime.strftime("%Y-%m-%d")
  end

  def time_parse(datetime)
    datetime.strftime("%H:%M")
  end
end
