# frozen_string_literal: true

require "debug"
require "date"
require "segment"
RSpec.describe Segment do
  it "create transport segment" do
    segment = Segment.new("SEGMENT: Train SVQ 2023-02-15 09:30 -> MAD 11:00")
    expect(segment.transport).to eq("Train")
    expect(segment.to).to eq("MAD")
    expect(segment.from).to eq("SVQ")
    expect(segment.departure_time).to eq(DateTime.new(2023, 2, 15, 9, 30))
    expect(segment.arrival_time).to eq(DateTime.new(2023, 2, 15, 11, 0))
  end

  it "create accommodation segment" do
    segment = Segment.new("SEGMENT: Resort MAD 2023-02-15 -> 2023-02-17")
    expect(segment.accomodation).to eq("Resort")
    expect(segment.to).to eq("MAD")
    expect(segment.from).to eq("MAD")
    expect(segment.departure_time).to eq(DateTime.new(2023, 2, 15, 23, 59))
    expect(segment.arrival_time).to eq(DateTime.new(2023, 2, 17, 0, 0))
  end

  # rubocop:disable Layout/ArgumentAlignment
  it "problem with date raise error" do
    date_error_segment = "SEGMENT: Train SVQ 2023-13-15 09:30 -> MAD 11:00"
    expect { Segment.new(date_error_segment) }.to raise_error(Error,
      "Problem with date in: [\"SEGMENT:\", \"Train\", \"SVQ\", \"2023-13-15\", \"09:30\", \"->\", \"MAD\", \"11:00\"]")
  end

  it "segment with unexpected number of data raise error" do
    error_segment = "SEGMENT: Resort MAD 2023-02-15 -> 2023-02-17 12:00"
    expect { Segment.new(error_segment) }.to raise_error(Error,
      "Problem with size in: SEGMENT: Resort MAD 2023-02-15 -> 2023-02-17 12:00")
  end
  # rubocop:enable Layout/ArgumentAlignment

  it "write output transport" do
    segment = Segment.new("SEGMENT: Train SVQ 2023-02-15 09:30 -> MAD 11:00")
    output = "Train from SVQ to MAD at 2023-02-15T09:30:00+00:00 to 2023-02-15T11:00:00+00:00"
    expect(segment.write_output).to eq(output)
  end

  it "write output accomodation" do
    segment = Segment.new("SEGMENT: Resort MAD 2023-02-15 -> 2023-02-17")
    output = "Resort at MAD on 2023-02-15T23:59:00+00:00 to 2023-02-17T00:00:00+00:00"
    expect(segment.write_output).to eq(output)
  end
end


