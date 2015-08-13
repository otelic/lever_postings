module LeverPostings
  class Posting
    def self.from_json(json)
      if json[0]
        postings = []
        json.each do |posting|
          postings << ::Hashie::Mash.new(posting)
        end
        postings
      elsif json != []
        ::Hashie::Mash.new(json)
      else
        json
      end
    end
  end
end
