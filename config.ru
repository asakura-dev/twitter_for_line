require 'bundler/setup'
require 'sinatra/base'
require 'json'
require 'rest-client'
require 'openssl'
require 'base64'
require 'twitter'

EVENT_TYPE_OPERATION = "138311609100106403"
EVENT_TYPE_MESSAGE = "138311609000106303"

class App < Sinatra::Base
  post '/linebot/callback' do
    request_body = request.body.read
    if request.env["HTTP_X_LINE_CHANNELSIGNATURE"] != computeSignature(request_body)
      puts "invalid Signature"
    else
      puts "valid Signature"
      params = JSON.parse(request_body)
      params['result'].each do |msg|
        tweet(msg['content']['text'].to_s)
      end
    end
  end
  def computeSignature(request_body)
    hash = OpenSSL::HMAC::digest(OpenSSL::Digest::SHA256.new,  ENV["LINE_CHANNEL_SECRET"], request_body)
    signature = Base64.strict_encode64(hash)
  end
  def tweet(message)
    client = Twitter::REST::Client.new do |config|
      config.consumer_key        = ENV["TWITTER_CONSUMER_KEY"]
      config.consumer_secret     = ENV["TWITTER_CONSUMER_SECRET_KEY"]
      config.access_token        = ENV["TWITTER_ACCESS_TOKEN"]
      config.access_token_secret = ENV["TWITTER_ACCESS_TOKEN_SECRET"]
    end
    client.update(message)
  end
end


run App
