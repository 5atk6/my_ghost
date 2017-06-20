require 'sinatra/base'
require 'slim'
require 'date'
require 'pry'
require 'json'
require 'faye/websocket'

module Whisper
  class App < Sinatra::Base
    configure do
      enable :logging
    end

    helpers do
      def protected!
        return if authorized?
        headers['WWW-Authenticate'] = 'Basic realm="Restricted Area"'
        halt 401, "Not authorized\n"
      end

      def authorized?
        @auth ||=  Rack::Auth::Basic::Request.new(request.env)
        @auth.provided? and @auth.basic? and @auth.credentials and @auth.credentials == ['admin', 'admin']
      end
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

      post_to_ws(hash)

      redis.lpush("whispers", hash.to_json)
      set_whispers
      slim :"new.html"
    end

    # To select a question in the whispers
    get "/index" do
      protected!
      set_whispers
      slim :"index.html"
    end

    get "/assets/js/ws.js" do
      content_type :js
      @scheme = ENV['RACK_ENV'] == "production" ? "wss://" : "ws://"
      erb :"ws.js"
    end

    get "/assets/js/ws_for_public.js" do
      content_type :js
      @scheme = ENV['RACK_ENV'] == "production" ? "wss://" : "ws://"
      erb :"ws_for_public.js"
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
      @whispers = redis.lrange("whispers", 0, 50)
      @whispers = @whispers.map { |json| JSON.parse(json) }
    end

    def post_to_ws(hash)
      hash['func'] = 'post'
      channel = Whisper::WhisperBackend::CHANNEL
      redis.publish(channel, hash.to_json)
    end
  end
end
