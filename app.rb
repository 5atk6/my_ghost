require 'sinatra/base'
require 'slim'
require 'date'
require 'pry'
require 'json'

module Whisper
  class App < Sinatra::Base
    configure do
      enable :logging
    end

    # To get form
    get "/" do
      set_whispers
      slim :"new.html"
    end

    # To post whisper
    post "/" do
      datetime = DateTime.now
      datetime = datetime.new_offset('+09:00')
      date_str = datetime.strftime("%Y/%m/%d %H:%M:%S")
      hash = { text: params['message'], created_at: date_str }
      redis.lpush("whispers", hash.to_json)
      set_whispers
      slim :"new.html"
    end

    # To select a question in the whispers
    get "/index" do
      set_whispers
      slim :"index.html"
    end

    get "/assets/js/ws.js" do
      content_type :js
      @scheme = ENV['RACK_ENV'] == "production" ? "wss://" : "ws://"
      erb :"ws.js"
    end

    private

    def redis
      return @redis if @redis

      url = ENV["REDIS_URL"] || 'redis://localhost:6379'
      encoded_url = URI.encode(url)
      uri = URI.parse(encoded_url)
      @redis = Redis.new(host: uri.host, port: uri.port, password: uri.password)
    end

    def set_whispers
      @whispers = redis.lrange("whispers", -20, 20)
      @whispers = @whispers.map { |json| JSON.parse(json) }
    end
  end
end
