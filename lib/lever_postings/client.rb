module LeverPostings
  class Client
    attr_accessor :account, :api, :connection

    def initialize(api, account)
      @api = api
      @account = account
      @connection = Faraday.new url: "https://api.lever.co/v0/" do |conn|
        # POST/PUT params encoders:
        conn.request :multipart
        conn.request :url_encoded
        conn.adapter :net_http
      end
    end

    def get(path, params = {})
      request :get, path, {}, params
    end

    def post(path, options = {}, params = {})
      request :post, path, options, params
    end

    def request(method, path, options = {}, params = {})
      path = path && path != "" ? "/#{path}" : nil
      url = "#{api}/#{account}#{path}"

      if options.key?(:api_key)
        url = url + "?key=#{options[:api_key]}"
      end

      if method == :post
        response = connection.post(url, params)
        response
      else
        connection.params = params
        response = connection.send(method, url)
        if response.status == 200
          if params[:mode] == "json"
            MultiJson.load(response.body, symbolize_keys: true)
          else
            response.body
          end
        else
          fail LeverPostings::Error.new("#{response.status}: #{response.body}", response.status)
        end
      end
    end
  end
end
