# frozen_string_literal: true

require "debug"
# rubocop:disable Metrics/BlockLength
RSpec.describe Fcm do
  it "has a version number" do
    expect(Fcm::VERSION).not_to be nil
  end

  it "if there is not a based env" do
    expect(Fcm).not_to receive(:read_file)
    Fcm.run
  end

  it "return error if not based env" do
    error_output = "Error: not passed BASED environment variable\n"
    expect { Fcm.run }.to output(error_output).to_stdout
  end

  context "with based not related to data" do
    before do
      Dotenv.load("no_data.env")
    end

    it "not output" do
      ARGV.clear
      ARGV += ["lib/input.txt"]
      expect { Fcm.run }.to output("").to_stdout
    end
  end

  context "with based" do
    before do
      Dotenv.load
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

    it "return error if not file" do
      error_output = "Error: not passed file to read\n"
      expect { Fcm.run }.to output(error_output).to_stdout
    end

    it "file is not txt not read" do
      ARGV.clear
      ARGV += ["lib/input.csv"]
      expect(Fcm).not_to receive(:read_file)
      Fcm.run
    end

    it "print error file is not a txt" do
      ARGV.clear
      ARGV += ["lib/input.csv"]
      error_output = "Error: file is not a txt\n"
      expect { Fcm.run }.to output(error_output).to_stdout
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

    it "print error is not right data in file" do
      ARGV.clear
      ARGV += ["spec/empty_data.txt"]
      error_output = "Error: not right data in the file\n"
      expect { Fcm.run }.to output(error_output).to_stdout
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

    it "with not create segments not call sorted_segments" do
      ARGV.clear
      ARGV += ["spec/segment_error.txt"]
      expect(Fcm).not_to receive(:sorted_segments)
      Fcm.run
    end

    # rubocop:disable Layout/LineLength
    it "when we dont create segments because info is wrong" do
      ARGV.clear
      ARGV += ["spec/segment_error.txt"]
      error_output = "Error with line: Problem with size in: SEGMENT: Flight SVQ 2023-03-02 06:40 -> BCN 2023-03-02 09:10\n" \
                     "Error with line: Problem with date in: [\"SEGMENT:\", \"Hotel\", \"BCN\", \"2023-13-05\", \"->\", \"2023-01-10\"]\n" \
                     "Error with line: Problem with date in: [\"SEGMENT:\", \"Flight\", \"SVQ\", \"2023-01-05\", \"20:40\", \"->\", \"BCN\", \"25:10\"]\n" \
                     "Error with line: Problem with date in: [\"SEGMENT:\", \"Flight\", \"BCN\", \"2023-14-10\", \"10:30\", \"->\", \"SVQ\", \"11:50\"]\n" \
                     "Error: no created segments\n"
      expect { Fcm.run }.to output(error_output).to_stdout
    end
    # rubocop:enable Layout/LineLength

    context "with segments created" do
      before do
        data = ["SEGMENT: Flight SVQ 2023-03-02 06:40 -> BCN 09:10",
                "SEGMENT: Hotel BCN 2023-01-05 -> 2023-01-10",
                "SEGMENT: Flight SVQ 2023-01-05 20:40 -> BCN 22:10",
                "SEGMENT: Flight BCN 2023-01-10 10:30 -> SVQ 11:50",
                "SEGMENT: Train SVQ 2023-02-15 09:30 -> MAD 11:00",
                "SEGMENT: Train MAD 2023-02-17 17:00 -> SVQ 19:30",
                "SEGMENT: Hotel MAD 2023-02-15 -> 2023-02-17",
                "SEGMENT: Flight BCN 2023-03-02 15:00 -> NYC 22:45"]
        @segments = Fcm.create_objects(data)
      end

      it "initial segments" do
        initial_segments = Fcm.initial_segments(@segments, "SVQ")
        expect(initial_segments.size).to eq(3)
      end

      it "order segments" do
        sorted_segments = Fcm.sorted_segments(@segments)

        expect(sorted_segments.first.to).to eq("BCN")
        expect(sorted_segments.first.departure_time).to eq(DateTime.new(2023, 1, 5, 20, 40))

        expect(sorted_segments.last.to).to eq("NYC")
      end

      it "group segments" do
        output = "TRIP to BCN\n" \
                 "Flight from SVQ to BCN at 2023-01-05 20:40 to 22:10\n" \
                 "Hotel at BCN on 2023-01-05 to 2023-01-10\n" \
                 "Flight from BCN to SVQ at 2023-01-10 10:30 to 11:50\n" \
                 "TRIP to MAD\n" \
                 "Train from SVQ to MAD at 2023-02-15 09:30 to 11:00\n" \
                 "Hotel at MAD on 2023-02-15 to 2023-02-17\n" \
                 "Train from MAD to SVQ at 2023-02-17 17:00 to 19:30\n" \
                 "TRIP to NYC\n" \
                 "Flight from SVQ to BCN at 2023-03-02 06:40 to 09:10\n" \
                 "Flight from BCN to NYC at 2023-03-02 15:00 to 22:45\n"
        sorted_segments = Fcm.sorted_segments(@segments)
        expect { Fcm.group_segments(sorted_segments, "SVQ") }.to output(output).to_stdout
      end
    end
  end

  context "with other based and data (file group data)" do
    before do
      Dotenv.load("other.env")
    end

    it "read_file" do
      ARGV.clear
      ARGV += ["spec/group_data.txt"]
      expect(Fcm).to receive(:read_file)
      Fcm.run
    end

    it "return info segment lines" do
      data = ["SEGMENT: Flight MAD 2025-01-01 06:40 -> BCN 09:10\n",
              "SEGMENT: Flight BCN 2025-01-01 11:40 -> IBZ 13:40\n",
              "SEGMENT: Flight MAD 2025-02-01 08:00 -> BIO 09:10\n",
              "SEGMENT: Train BIO 2025-02-01 09:30 -> EAS 12:00\n",
              "SEGMENT: Hotel IBZ 2025-01-01 -> 2025-01-08\n",
              "SEGMENT: Flight IBZ 2025-01-08 20:40 -> MAD 22:10\n",
              "SEGMENT: Train EAS 2025-02-10 10:40 -> BIO 12:00\n",
              "SEGMENT: Fligth BIO 2025-02-10 12:30 -> MAD 14:30\n",
              "SEGMENT: Fligth MAD 2025-03-08 11:35 -> BCN 13:00"]
      expect(Fcm.read_file("spec/group_data.txt")).to eq(data)
    end

    context "with segments created" do
      before do
        @output = "TRIP to IBZ\n" \
                  "Flight from MAD to BCN at 2025-01-01 06:40 to 09:10\n" \
                  "Flight from BCN to IBZ at 2025-01-01 11:40 to 13:40\n" \
                  "Hotel at IBZ on 2025-01-01 to 2025-01-08\n" \
                  "Flight from IBZ to MAD at 2025-01-08 20:40 to 22:10\n" \
                  "TRIP to EAS\n" \
                  "Flight from MAD to BIO at 2025-02-01 08:00 to 09:10\n" \
                  "Train from BIO to EAS at 2025-02-01 09:30 to 12:00\n" \
                  "Train from EAS to BIO at 2025-02-10 10:40 to 12:00\n" \
                  "Fligth from BIO to MAD at 2025-02-10 12:30 to 14:30\n" \
                  "TRIP to BCN\n" \
                  "Fligth from MAD to BCN at 2025-03-08 11:35 to 13:00\n"
        data = ["SEGMENT: Flight MAD 2025-01-01 06:40 -> BCN 09:10\n",
                "SEGMENT: Flight BCN 2025-01-01 11:40 -> IBZ 13:40\n",
                "SEGMENT: Flight MAD 2025-02-01 08:00 -> BIO 09:10\n",
                "SEGMENT: Train BIO 2025-02-01 09:30 -> EAS 12:00\n",
                "SEGMENT: Hotel IBZ 2025-01-01 -> 2025-01-08\n",
                "SEGMENT: Flight IBZ 2025-01-08 20:40 -> MAD 22:10\n",
                "SEGMENT: Train EAS 2025-02-10 10:40 -> BIO 12:00\n",
                "SEGMENT: Fligth BIO 2025-02-10 12:30 -> MAD 14:30\n",
                "SEGMENT: Fligth MAD 2025-03-08 11:35 -> BCN 13:00"]
        @segments = Fcm.create_objects(data)
      end

      it "initial segments" do
        initial_segments = Fcm.initial_segments(@segments, "MAD")
        expect(initial_segments.size).to eq(3)
      end

      it "order segments" do
        sorted_segments = Fcm.sorted_segments(@segments)

        expect(sorted_segments.first.to).to eq("BCN")
        expect(sorted_segments.first.departure_time).to eq(DateTime.new(2025, 1, 1, 6, 40))

        expect(sorted_segments.last.to).to eq("BCN")
        expect(sorted_segments.last.arrival_time).to eq(DateTime.new(2025, 3, 8, 13, 0))
      end

      it "group segments" do
        sorted_segments = Fcm.sorted_segments(@segments)
        expect { Fcm.group_segments(sorted_segments, "MAD") }.to output(@output).to_stdout
      end
    end
  
    context "when we don't have info for return in a previous trip" do
      it "read_file" do
        ARGV.clear
        ARGV += ["spec/lack_info.txt"]
        expect(Fcm).to receive(:read_file)
        Fcm.run
      end

      it "return info segment lines" do
        data = ["SEGMENT: Flight SVQ 2023-03-02 06:40 -> BCN 09:10\n",
                "SEGMENT: Hotel BCN 2023-01-05 -> 2023-01-10\n",
                "SEGMENT: Flight SVQ 2023-01-05 20:40 -> BCN 22:10\n",
                "SEGMENT: Flight BCN 2023-03-10 10:30 -> SVQ 11:50"]
        expect(Fcm.read_file("spec/lack_info.txt")).to eq(data)
      end

      context "with segments created" do
        before do
          @output = "TRIP to BCN\n" \
                    "Flight from SVQ to BCN at 2023-01-05 20:40 to 22:10\n" \
                    "Hotel at BCN on 2023-01-05 to 2023-01-10\n" \
                    "TRIP to BCN\n" \
                    "Flight from SVQ to BCN at 2023-03-02 06:40 to 09:10\n" \
                    "Fligth from BCN to SVQ at 2023-03-10 10:30 to 11:50\n"
          data = ["SEGMENT: Flight SVQ 2023-03-02 06:40 -> BCN 09:10\n",
                  "SEGMENT: Hotel BCN 2023-01-05 -> 2023-01-10\n",
                  "SEGMENT: Flight SVQ 2023-01-05 20:40 -> BCN 22:10\n",
                  "SEGMENT: Fligth BCN 2023-03-10 10:30 -> SVQ 11:50\n"]
          @segments = Fcm.create_objects(data)
        end

        it "initial segments" do
          initial_segments = Fcm.initial_segments(@segments, "SVQ")
          expect(initial_segments.size).to eq(2)
        end

        it "order segments" do
          sorted_segments = Fcm.sorted_segments(@segments)

          expect(sorted_segments.first.to).to eq("BCN")
          expect(sorted_segments.first.departure_time).to eq(DateTime.new(2023, 1, 5, 20, 40))

          expect(sorted_segments.last.to).to eq("SVQ")
          expect(sorted_segments.last.arrival_time).to eq(DateTime.new(2023, 3, 10, 11, 50))
        end

        it "group segments" do
          sorted_segments = Fcm.sorted_segments(@segments)
          expect { Fcm.group_segments(sorted_segments, "SVQ") }.to output(@output).to_stdout
        end
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
