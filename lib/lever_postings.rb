require "faraday"
require "hashie"
require "multi_json"

require "lever_postings/client"
require "lever_postings/error"
require "lever_postings/posting"
require "lever_postings/version"

module LeverPostings
  def self.apply(account, api_key, params)
    postings_api = LeverPostings::Client.new("postings", account)
    posting_id = params[:posting_id]
    results = postings_api.post(posting_id, { api_key: api_key }, params)
    results
  end

  def self.postings(account, params = {})
    params[:mode] ||= "json"
    postings_api = LeverPostings::Client.new("postings", account)
    results = postings_api.get(params.delete(:id), params)

    if params.key?(:mode) && params[:mode] == "html"
      results
    else
      Posting.from_json(results)
    end
  end
end
