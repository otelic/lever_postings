require "pry"
require "spec_helper"

describe LeverPostings do
  it "has a version number" do
    expect(LeverPostings::VERSION).not_to be nil
  end

  describe "#apply" do
    context "success" do
      context "with resume" do
        it "successfully applies for the given job" do
          VCR.use_cassette("apply-success-with-resume", record: :new_episodes) do
            response = LeverPostings.apply "leverdemo",
              "TpOje1LNAqrS5Uw0PCZk",
              {
                posting_id: "491029da-9b63-4208-83f6-c976b6fe2ac5",
                name: "Test Application",
                email: "withresume@example.com",
                resume: File.open(File.expand_path('../fixtures/resume.txt', __FILE__)),
                phone: "415-555-5555",
                org: "Test Organization",
                urls: { github: "https://github.com/lever", twitter: "https://twitter.com/lever" },
                comments: "Comments",
                silent: true,
              }
            # DEBUG: puts pp response
            expect(MultiJson.load(response.body, symbolize_keys: true)[:ok]).to eq false
            expect(response.status).to eq 200
          end
        end
      end

      context "without resume" do
        it "successfully applies for the given job" do
          VCR.use_cassette("apply-success-without-resume", record: :new_episodes) do
            response = LeverPostings.apply "leverdemo",
              "TpOje1LNAqrS5Uw0PCZk",
              {
                posting_id: "491029da-9b63-4208-83f6-c976b6fe2ac5",
                name: "Test Application",
                email: "withoutresume@example.com",
                phone: "415-555-5555",
                org: "Test Organization",
                urls: { github: "https://github.com/lever", twitter: "https://twitter.com/lever" },
                comments: "Comments",
                silent: true,
              }
            expect(MultiJson.load(response.body, symbolize_keys: true)[:ok]).to eq false
            expect(response.status).to eq 200
          end
        end
      end
    end

    context "failure" do
      it "fails due to lack of data" do
        VCR.use_cassette("apply-fail-data", record: :new_episodes) do
          response = LeverPostings.apply "leverdemo",
            "TpOje1LNAqrS5Uw0PCZk",
            {
              posting_id: "491029da-9b63-4208-83f6-c976b6fe2ac5",
            }
          expect(MultiJson.load(response.body, symbolize_keys: true)[:ok]).to eq false
          expect(response.status).to eq 200
        end
      end

      it "fails due to incorrect api key" do
        VCR.use_cassette("apply-fail-api-key") do
          response = LeverPostings.apply "leverdemo",
            "invalidkey",
            {
              posting_id: "491029da-9b63-4208-83f6-c976b6fe2ac5",
            }
          expect(MultiJson.load(response.body, symbolize_keys: true)[:ok]).to eq false
          expect(response.status).to eq 403
        end
      end
    end
  end

  describe "#postings" do
    context "given no id" do
      before do
        VCR.use_cassette("postings") do
          @postings = LeverPostings.postings "leverdemo"
        end
      end

      it "returns a response" do
        expect(@postings).to_not be_nil
        expect(@postings.size).to be > 0
      end

      it "returns an array of postings" do
        expect(@postings).to be_an_instance_of(Array)
      end

      it "returns posting details" do
        expect(@postings.first).to have_key(:text)
      end
    end

    context "given an id" do
      before do
        VCR.use_cassette("posting") do
          @posting = LeverPostings.postings "leverdemo", id: "6d5cbe7f-e551-4ae1-b052-08a48f651993"
        end
      end

      it "returns a response" do
        expect(@posting).to_not be_nil
      end

      it "returns a posting's hash" do
        expect(@posting).to be_an_instance_of(::Hashie::Mash)
      end

      it "returns a posting's details" do
        expect(@posting).to have_key(:text)
      end
    end

    context "with parameters" do
      it "correctly applies multiple parameters" do
        VCR.use_cassette("postings") do
          @all_postings = LeverPostings.postings "leverdemo"
        end

        VCR.use_cassette("postings-multiple-params") do
          @postings = LeverPostings.postings "leverdemo", limit: 10, location: "San Francisco"
          @postings.collect { |p| p.categories.location }.each do |location|
            expect(location.downcase).to eq "san francisco"
          end
          expect(@postings.size).to eq 10
        end
      end

      describe "mode" do
        it "correctly applies mode" do
          VCR.use_cassette("postings-html") do
            @postings = LeverPostings.postings "leverdemo", mode: "html"
            expect(@postings).to include "<!DOCTYPE html>"
          end
        end
      end

      describe "skip" do
        it "correctly applies skip" do
          VCR.use_cassette("postings-skip") do
            @postings = LeverPostings.postings "leverdemo", skip: 1
          end
          expect(@postings.size).to eq 27
        end
      end

      describe "limit" do
        it "correctly applies limit" do
          VCR.use_cassette("postings-limit") do
            @postings = LeverPostings.postings "leverdemo", limit: 1
          end
          expect(@postings.length).to eq 1
        end
      end

      describe "location" do
        it "correctly applies location" do
          VCR.use_cassette("postings-location") do
            @postings = LeverPostings.postings "leverdemo", location: "San Francisco"
          end
          expect(@postings.length).to be > 0
          @postings.collect { |p| p.categories.location }.each do |location|
            expect(location.downcase).to eq "san francisco"
          end
        end

        # it "correctly applies multiple locations" do
        #   VCR.use_cassette("postings-locations", record: :new_episodes) do
        #     @postings = LeverPostings.postings "leverdemo", location: "San Francisco, Mountain View"
        #   end
        #   expect(@postings.length).to be > 0
        #   @postings.collect { |p| p.categories.location }.each do |location|
        #     expect(location.downcase).to eq "san francisco".or "mountain view"
        #   end
        # end
      end

      describe "commitment" do
        it "correctly applies commitment" do
          VCR.use_cassette("postings-commitment") do
            @postings = LeverPostings.postings "leverdemo", commitment: "Full-time"
          end
          expect(@postings.length).to be > 0
          @postings.collect { |p| p.categories.commitment }.each do |commitment|
            expect(commitment.downcase).to eq "full-time"
          end
        end

        # it "correctly applies multiple commitments" do
        #   VCR.use_cassette("postings-commitments", record: :new_episodes) do
        #     @postings = LeverPostings.postings "leverdemo", commitment: "Full-time, Part-time"
        #   end
        #   expect(@postings.length).to be > 0
        #   @postings.collect { |p| p.categories.commitment }.each do |commitment|
        #     expect(commitment.downcase).to eq "full-time".or "part-time"
        #   end
        # end
      end

      describe "team" do
        it "correctly applies team" do
          VCR.use_cassette("postings-team") do
            @postings = LeverPostings.postings "leverdemo", team: "Engineering"
          end
          expect(@postings.length).to be > 0
          @postings.collect { |p| p.categories.team }.each do |team|
            expect(team.downcase).to eq "engineering"
          end
        end

        # it "correctly applies multiple teams" do
        #   VCR.use_cassette("postings-teams", record: :new_episodes) do
        #     @postings = LeverPostings.postings "leverdemo", team: "Engineering, Marketing"
        #   end
        #   expect(@postings.length).to be > 0
        #   @postings.collect { |p| p.categories.team }.each do |team|
        #     expect(team.downcase).to eq "engineering".or "marketing"
        #   end
        # end
      end

      describe "level" do
        it "correctly applies level" do
          VCR.use_cassette("postings-level") do
            @postings = LeverPostings.postings "leverdemo", level: "senior"
          end
          expect(@postings.length).to be > 0
          @postings.collect { |p| p.categories.level }.each do |level|
            expect(level.downcase).to eq "senior"
          end
        end
      end

      describe "group" do
        it "correctly applies group" do
          VCR.use_cassette("postings-group") do
            @postings = LeverPostings.postings "leverdemo", group: "location"
          end
          expect(@postings.length).to be > 0

          @locations_visited = []
          @previous_location = nil
          @postings.each do |posting|
            location = posting.title
            if location != @previous_location
              expect(@locations_visited).to_not include(location)
              @previous_location = location
              @locations_visited |= [location]
            else
              expect(@locations_visited).to include(location)
            end
          end
        end
      end
    end

    it "returns 404 when account is invalid" do
      VCR.use_cassette("invalidaccount") do
        expect { LeverPostings.postings "invalidaccount" }.to raise_error LeverPostings::Error
      end
    end
  end
end
