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
    expect(transport.destination).to eq("BCN")
    expect(transport.departure_place).to eq("SVQ")
    expect(transport.departure_time).to eq(DateTime.new(2023, 3, 2, 6, 40))
    expect(transport.arrival_time).to eq(DateTime.new(2023, 3, 2, 9, 10))
    expect(transport.transport).to eq("Flight")

    expect(accomodation.accomodation).to eq("Hotel")
    expect(accomodation.destination).to eq("BCN")
    expect(accomodation.arrival_time).to eq(DateTime.new(2023, 1, 5, 0 ,0))
    expect(accomodation.departure_time).to eq(DateTime.new(2023, 1, 10, 0, 0))
  end

  it "segment with error write error information" do
    data = ["SEGMENT: Train SVQ 2023-13-15 09:30 -> MAD 11:00",
            "SEGMENT: Resort MAD 2023-02-15 -> 2023-02-17 12:00"]
    error_msg = "Error with line: Problem with date in:" +
    " #{["SEGMENT:", "Train", "SVQ", "2023-13-15", "09:30", "->", "MAD", "11:00"]}\n" +
    "Error with line: Problem with size in: SEGMENT: Resort MAD 2023-02-15 -> 2023-02-17 12:00\n"

    expect { Fcm.create_objects(data)}.to output(error_msg).to_stdout
  end
end
# rubocop:enable Metrics/BlockLength
