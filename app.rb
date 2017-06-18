require 'sinatra/base'
require 'slim'

module Whisper
  class App < Sinatra::Base
    configure do
      enable :logging
    end

    # to get form
    get "/" do
      slim :"new.html"
    end

    # To post ghost 
    post "/" do
      # TODO: create scheme on redis
      # TODO: and save object to redis
      puts params
      slim :"new.html"
    end

    # To select the ghosts
    get "/index" do
      slim :"index.html"
    end

    get "/assets/js/ws.js" do
      content_type :js
      @scheme = ENV['RACK_ENV'] == "production" ? "wss://" : "ws://"
      erb :"ws.js"
    end
  end
end
