require "spec_helper"

describe LeverPostings::Client do
  before do
    @client = LeverPostings::Client.new("postings", "leverdemo")
  end

  describe "#initialize" do
    it "has an account" do
      expect(@client.account).to eq("leverdemo")
    end

    it "has an api" do
      expect(@client.api).to eq("postings")
    end

    it "has a connection" do
      expect(@client.connection).to_not eq nil
    end

    it "raises error when no account is provided" do
      expect { LeverPostings::Client.new }.to raise_error ArgumentError
    end
  end

  describe "#get" do
    it "applies params to requests" do
      expect(@client).to receive(:request).with(:get, "", {}, mode: "json")
      VCR.use_cassette("postings") do
        @client.get("", mode: "json")
      end
    end
  end

  describe "#post" do
    it "applies params to requests" do
      expect(@client).to receive(:request).with(:post,
        "491029da-9b63-4208-83f6-c976b6fe2ac5", {}, api_key: "123")
      VCR.use_cassette("apply-to-posting") do
        @client.post("491029da-9b63-4208-83f6-c976b6fe2ac5", {}, api_key: "123")
      end
    end
  end

  describe "#request" do
    it "returns parsed json when request is successful" do
      VCR.use_cassette("postings") do
        postings = @client.request(:get, "", {}, mode: "json")
        expect(postings).to be_an_instance_of(Array)
        expect(postings.first[:text]).to eq "Account Executive"
      end
    end

    it "raises an error when request fails" do
      VCR.use_cassette("failed-request") do
        expect { @client.request(:get, "alksdjflajdsf") }.to raise_error LeverPostings::Error
      end
    end
  end
end
