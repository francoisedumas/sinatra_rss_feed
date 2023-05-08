require 'sinatra'
require 'dotenv'
require 'httparty'
require 'airrecord'
Dotenv.load

def get_rss_feeds
  answer = HTTParty.get(
    "https://api.airtable.com/v0/#{ENV['AIRTABLE_BASE_ID']}/#{ENV['AIRTABLE_TABLE_NAME']}",
    headers: {
      "Authorization" => "Bearer #{ENV['AIRTABLE_API_KEY']}"
    }
  )
  @answer = JSON.parse(answer.body)["records"]
end

def create_rss_feed(url)
  HTTParty.post(
    "https://api.airtable.com/v0/#{ENV['AIRTABLE_BASE_ID']}/#{ENV['AIRTABLE_TABLE_NAME']}",
    headers: {
      "Authorization" => "Bearer #{ENV['AIRTABLE_API_KEY']}",
      "Content-Type" => "application/json"
    },
    body: {
      "records": [
        {
          "fields": {
            "url": url
          }
        }
      ]
    }.to_json
  )
end

# Airrecord.api_key = ENV['AIRTABLE_API_KEY']
# class RssFeed < Airrecord::Table
#   self.base_key = ENV['AIRTABLE_BASE_ID']
#   self.table_name = ENV['AIRTABLE_TABLE_NAME']
# end

get '/' do
  erb 'index.html'.to_sym
end

# Define routes for the app
get '/rss_feeds' do
  @rss_feeds = get_rss_feeds
  # @rss_feeds = RssFeed.all
  erb 'rss_feeds/index.html'.to_sym
end

get '/rss_feeds/new' do
  erb 'rss_feeds/new.html'.to_sym
end

post '/rss_feeds' do
  create_rss_feed(params[:url])

  # # Save the RSS feed URL to Airtable
  # RssFeed.create(
  #   'url' => url
  # )

  redirect '/rss_feeds'
end
