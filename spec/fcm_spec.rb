# frozen_string_literal: true

require "debug"
# rubocop:disable Metrics/BlockLength
RSpec.describe Fcm do
  it "has a version number" do
    expect(Fcm::VERSION).not_to be nil
  end

  it "read_file" do
    ARGV.clear
    ARGV += ["lib/input.txt"]
    expect(Fcm).to receive(:read_file)
    Fcm.run
  end

  it "there is not file not read_file" do
    ARGV.clear
    expect(Fcm).not_to receive(:read_file)
    Fcm.run
  end

  it "file is not txt not read" do
    ARGV.clear
    ARGV += ["lib/input.csv"]
    expect(Fcm).not_to receive(:read_file)
    Fcm.run
  end

  it "return info segment lines" do
    data = ["SEGMENT: Flight SVQ 2023-03-02 06:40 -> BCN 09:10\n",
            "SEGMENT: Hotel BCN 2023-01-05 -> 2023-01-10\n",
            "SEGMENT: Flight SVQ 2023-01-05 20:40 -> BCN 22:10\n",
            "SEGMENT: Flight BCN 2023-01-10 10:30 -> SVQ 11:50"]
    expect(Fcm.read_file("spec/test_data.txt")).to eq(data)
  end

  it "not return data if line dont include word SEGMENT" do
    data = ["SEGMENTO: Flight SVQ 2023-03-02 06:40 -> BCN 09:10\n",
            "SEGMENT: Hotel BCN 2023-01-05 -> 2023-01-10\n",
            "SEGMENT: Train SVQ 2023-13-15 09:30 -> MAD 11:00\n",
            "SEGMENT: Resort MAD 2023-02-15 -> 2023-02-17 12:00"]
    expect(Fcm.read_file("spec/error_data.txt")).to eq(data)
  end

  it "return empty array if none line include word SEGMENT" do
    data = []
    expect(Fcm.read_file("spec/empty_data.txt")).to eq(data)
  end

  it "data empty not call create_objects" do
    ARGV.clear
    ARGV += ["spec/empty_data.txt"]
    expect(Fcm).not_to receive(:create_objects)
  end

  it "create_objects" do
    ARGV.clear
    ARGV += ["lib/input.txt"]
    expect(Fcm).to receive(:create_objects)
    Fcm.run
  end

  it "create all segments" do
    data = ["SEGMENTO: Flight SVQ 2023-03-02 06:40 -> BCN 09:10\n",
            "SEGMENT: Hotel BCN 2023-01-05 -> 2023-01-10\n"]
    segments = Fcm.create_objects(data)
    expect(segments.size).to eq(2)
    transport = segments[0]
    accomodation = segments[1]
    expect(transport.to).to eq("BCN")
    expect(transport.from).to eq("SVQ")
    expect(transport.departure_time).to eq(DateTime.new(2023, 3, 2, 6, 40))
    expect(transport.arrival_time).to eq(DateTime.new(2023, 3, 2, 9, 10))
    expect(transport.transport).to eq("Flight")

    expect(accomodation.accomodation).to eq("Hotel")
    expect(accomodation.to).to eq("BCN")
    expect(accomodation.from).to eq("BCN")
    expect(accomodation.departure_time).to eq(DateTime.new(2023, 1, 5, 23, 59))
    expect(accomodation.arrival_time).to eq(DateTime.new(2023, 1, 10, 0, 0))
  end

  it "segment with error write error information" do
    data = ["SEGMENT: Train SVQ 2023-13-15 09:30 -> MAD 11:00",
            "SEGMENT: Resort MAD 2023-02-15 -> 2023-02-17 12:00"]
    error_msg = "Error with line: Problem with date in: " \
                "[\"SEGMENT:\", \"Train\", \"SVQ\", \"2023-13-15\", \"09:30\", \"->\", \"MAD\", \"11:00\"]\n" \
                "Error with line: Problem with size in: SEGMENT: Resort MAD 2023-02-15 -> 2023-02-17 12:00\n"

    expect { Fcm.create_objects(data) }.to output(error_msg).to_stdout
  end

  it "order segments" do
    data = ["SEGMENT: Flight SVQ 2023-03-02 06:40 -> BCN 09:10",
            "SEGMENT: Hotel BCN 2023-01-05 -> 2023-01-10",
            "SEGMENT: Flight SVQ 2023-01-05 20:40 -> BCN 22:10",
            "SEGMENT: Flight BCN 2023-01-10 10:30 -> SVQ 11:50",
            "SEGMENT: Train SVQ 2023-02-15 09:30 -> MAD 11:00",
            "SEGMENT: Train MAD 2023-02-17 17:00 -> SVQ 19:30",
            "SEGMENT: Hotel MAD 2023-02-15 -> 2023-02-17",
            "SEGMENT: Flight BCN 2023-03-02 15:00 -> NYC 22:45"
            ]
    segments = Fcm.create_objects(data)
    sorted_segments = Fcm.sorted_segments(segments)

    expect(sorted_segments.first.to).to eq("BCN")
    expect(sorted_segments.first.departure_time).to eq(DateTime.new(2023, 1, 5, 20, 40))

    expect(sorted_segments.last.to).to eq("NYC")
  end

  it "group segments" do
    data = ["SEGMENT: Flight SVQ 2023-03-02 06:40 -> BCN 09:10",
            "SEGMENT: Hotel BCN 2023-01-05 -> 2023-01-10",
            "SEGMENT: Flight SVQ 2023-01-05 20:40 -> BCN 22:10",
            "SEGMENT: Flight BCN 2023-01-10 10:30 -> SVQ 11:50",
            "SEGMENT: Train SVQ 2023-02-15 09:30 -> MAD 11:00",
            "SEGMENT: Train MAD 2023-02-17 17:00 -> SVQ 19:30",
            "SEGMENT: Hotel MAD 2023-02-15 -> 2023-02-17",
            "SEGMENT: Flight BCN 2023-03-02 15:00 -> NYC 22:45"
            ]

    output = "TRIP TO BCN\n" +
            "Flight from SVQ to BCN at 2023-01-05T20:40:00+00:00 to 2023-01-05T22:10:00+00:00\n" +
            "Hotel at BCN on 2023-01-05T23:59:00+00:00 to 2023-01-10T00:00:00+00:00\n" +
            "Flight from BCN to SVQ at 2023-01-10T10:30:00+00:00 to 2023-01-10T11:50:00+00:00\n" +
            "TRIP TO MAD\n" +
            "Train from SVQ to MAD at 2023-02-15T09:30:00+00:00 to 2023-02-15T11:00:00+00:00\n" +
            "Hotel at MAD on 2023-02-15T23:59:00+00:00 to 2023-02-17T00:00:00+00:00\n" +
            "Train from MAD to SVQ at 2023-02-17T17:00:00+00:00 to 2023-02-17T19:30:00+00:00\n" +
            "TRIP TO BCN\n" +
            "Flight from SVQ to BCN at 2023-03-02T06:40:00+00:00 to 2023-03-02T09:10:00+00:00\n" +
            "Flight from BCN to NYC at 2023-03-02T15:00:00+00:00 to 2023-03-02T22:45:00+00:00\n"
    segments = Fcm.create_objects(data)
    sorted_segments = Fcm.sorted_segments(segments)
    expect {Fcm.group_segments(sorted_segments, "SVQ")}.to output(output).to_stdout
  end
end
# rubocop:enable Metrics/BlockLength
