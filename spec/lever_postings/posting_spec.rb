require 'spec_helper'

describe LeverPostings::Posting do
  describe "#from_json" do
    it "converts json into Hashie::Mash" do
      json = MultiJson.load('{ "name": "Spock" }')
      expect(LeverPostings::Posting.from_json(json).name).to eq "Spock"
    end
  end
end
