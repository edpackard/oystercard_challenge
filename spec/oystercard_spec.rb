require "oystercard"

describe Oystercard do 

  let (:station) { double :station }
  let (:station2) { double :station2 }

  describe "initialized instance variables" do
    it "initializes starting balance as a constant" do
      expect(subject.balance).to eq Oystercard::STARTING_BALANCE
    end
    it "initializes @journeys as empty" do
      expect(subject.journeys).to be_empty
    end
  end

  describe '#top_up' do
    it "adds money to card" do
      expect { subject.top_up(5) }.to change { subject.balance }.by(5)
    end

    it "limits balance to a maximum constant" do
      subject.top_up(Oystercard::MAX_TOP_UP)
      expect { subject.top_up(5) }.to raise_error "Error: Cannot exceed max balance of 90"
    end
  end

  describe "#touch_in" do

  before(:each) do
    allow(station).to receive(:get_name).and_return("name")
    allow(station).to receive(:get_zone).and_return("zone")
  end

    context "no funds" do
     
      it "raises an error if insufficient funds" do
        name = station.get_name
        zone = station.get_zone
        expect { subject.touch_in(name, zone) }.to raise_error "Insufficient funds!"
      end
    end
    
    context "with funds" do
      before(:each) do
        subject.top_up(Oystercard::MINIMUM_FARE)
        name = station.get_name
        zone = station.get_zone
        subject.touch_in(name, zone)
      end

      it "sets in_journey? status as true" do
        expect(subject.in_journey?).to be true
      end

      it "creates hash to store entry and exit stations" do
        expect(subject.journey).to be_a Hash
      end

      it "adds entry station to journey hash" do
        expect(subject.journey).to include(entry_station: "name")
      end

      it "adds entry station zone to journey hash" do
        expect(subject.journey).to include(entry_zone: "zone")
      end
    end
  end

  describe "#touch_out" do

    context "check min fare" do

      it "deducts minimum fare" do
        subject.top_up(Oystercard::MINIMUM_FARE)
        allow(station).to receive(:get_name).and_return("name")
        allow(station).to receive(:get_zone).and_return("zone")
        name = station.get_name
        zone = station.get_zone
        subject.touch_in(name, zone)
        expect { subject.touch_out(name,zone) }.to change { subject.balance }.by (-Oystercard::MINIMUM_FARE)
      end

    end

    context "check journey" do
    
      before(:each) do
        subject.top_up(Oystercard::MINIMUM_FARE)
        allow(station).to receive(:get_name).and_return("name")
        allow(station).to receive(:get_zone).and_return("zone")
        name = station.get_name
        zone = station.get_zone
        subject.touch_in(name, zone)
        subject.touch_out(name,zone)
      end

      it "sets in_journey? status as false" do
        expect(subject.in_journey?).to eq false
      end

      it "adds exit station to journey hash" do
        expect(subject.journey).to include(exit_station: "name")
      end
      
      it "adds exit zone to journey hash" do
        expect(subject.journey).to include(exit_zone: "zone")
      end
      
      it "adds journey data to journeys array" do
        hash = {entry_station: "name", exit_station: "name", entry_zone: "zone", exit_zone: "zone"}
        expect(subject.journeys).to contain_exactly(hash)
      end
    end
  end

end
