# frozen_string_literal: true

require "debug"
# rubocop:disable Metrics/BlockLength
RSpec.describe Fcm do
  it "has a version number" do
    expect(Fcm::VERSION).not_to be nil
  end

  it "read_file" do
    ARGV.clear
    ARGV += ["/lib/input.txt"]
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
    ARGV += ["/lib/input.csv"]
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
            "SEGMENT: Hotel BCN 2023-01-05 -> 2023-01-10\n"]
    expect(Fcm.read_file("spec/error_data.txt")).to eq(data)
  end

  it "return empty array if none line include word SEGMENT" do
    data = []
    expect(Fcm.read_file("spec/empty_data.txt")).to eq(data)
  end
end
# rubocop:enable Metrics/BlockLength
