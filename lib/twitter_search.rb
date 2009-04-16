require 'rubygems'
require 'net/http'
require 'json'
require 'cgi'
require 'actionpack'
module TwitterSearch

  class Tweet
    VARS = [:text, :from_user, :to_user, :to_user_id, :id, :iso_language_code, :from_user_id, :created_at, :profile_image_url ]
    attr_reader *VARS
    attr_reader :language
    
    def initialize(opts)
      @language = opts['iso_language_code']
      VARS.each { |each| instance_variable_set "@#{each}", opts[each.to_s] }
    end
  end

  class Tweets
    VARS = [:since_id, :max_id, :results_per_page, :page, :query, :next_page]
    attr_reader *VARS

    include Enumerable

    def initialize(opts)
      @results = opts['results'].collect { |each| Tweet.new(each) }
      VARS.each { |each| instance_variable_set "@#{each}", opts[each.to_s] }
    end

    def each(&block)
      @results.each(&block)
    end

    def size
      @results.size
    end
    
    def [](index)
      @results[index]
    end
  end

  class Client
    TWITTER_API_URL = 'http://search.twitter.com/search.json'
    TWITTER_API_DEFAULT_TIMEOUT = 5
    
    attr_accessor :agent
    
    def initialize(agent = 'twitter-search')
      @agent = agent
    end
    
    def headers
      { "Content-Type" => 'application/json',
        "User-Agent"   => @agent }
    end
    
    def timeout
      TWITTER_API_DEFAULT_TIMEOUT
    end
    
    def query(opts = {})
      url       = URI.parse(TWITTER_API_URL)
      url.query = sanitize_query(opts)
      
      req  = Net::HTTP::Get.new(url.path)
      http = Net::HTTP.new(url.host, url.port)
      http.read_timeout = timeout
      
      json = http.start { |http|
        http.get("#{url.path}?#{url.query}", headers)
      }.body
      Tweets.new JSON.parse(json)
    end

    private

      def sanitize_query(opts)
        if opts.is_a? String
          "q=#{CGI.escape(opts)}" 
        elsif opts.is_a? Hash
          "#{sanitize_query_hash(opts)}"
        end
      end

      def sanitize_query_hash(query_hash)
        query_hash.collect { |key, value| 
          "#{CGI.escape(key.to_s)}=#{CGI.escape(value.to_s)}" 
        }.join('&')
      end
  
  end

end
