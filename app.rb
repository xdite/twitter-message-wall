$LOAD_PATH << File.join(Dir.getwd, 'lib')
require 'rubygems'
require 'sinatra'
require 'sinatra_activerecord'
require 'twitter_search'
require 'will_paginate/array'
require 'will_paginate/view_helpers'
require 'lib/view_helpers'
get '/' do
  
  unless params[:page]
    @client = TwitterSearch::Client.new 'politweets'
    @results = @client.query :q => '@MrIE6'  
    
    @results.each do |result|
      tweet = Tweet.find_or_initialize_by_tweet_id(result.id)
      if tweet.new_record?
        tweet.text   = result.text
        tweet.from_user            = result.from_user
        tweet.to_user              = result.to_user
        tweet.from_user_id         = result.from_user_id
        tweet.to_user_id           = result.to_user_id
        tweet.created_at            = result.created_at 
        tweet.profile_image_url    = result.profile_image_url
        tweet.iso_language_code    = result.iso_language_code
        tweet.save
      end
    end
  end
  @tweets = Tweet.find(:all, :order => "created_at DESC").paginate :page => params[:page], :per_page => 10
  erb :home
end

class Tweet < ActiveRecord::Base  
  
end

configure  do
  ActiveRecord::Base.configurations = database_configuration
  ActiveRecord::Base.establish_connection(APP_ENV)
  ActiveRecord::Base.logger = Logger.new("log/activerecord.log") # Somehow you need logging right?
end


helpers do
  include TweetMessage::ViewHelpers
  include WillPaginate::ViewHelpers
end