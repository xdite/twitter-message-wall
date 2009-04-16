class CreateTweets < ActiveRecord::Migration
  def self.up
    create_table "tweets", :force => true do |t| 
      t.text :text
      t.string :from_user
      t.string :to_user
      t.integer :to_user_id
      t.integer :from_user_id
      t.datetime :created_at
      t.integer :tweet_id
      t.string :profile_image_url
      t.string :iso_language_code   
    end
  end

  def self.down
    drop_table "tweets"
  end
end
