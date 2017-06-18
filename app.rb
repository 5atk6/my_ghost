require 'sinatra/base'

module ChatDemo
  class App < Sinatra::Base
    # to get form
    get "/" do
      erb :"new.html"
    end

    # To post ghost 
    post "/" do
      # TODO: create scheme on redis
      # TODO: and save object to redis
      erb :"new.html"
    end

    # To select the ghosts
    get "/index" do
      erb :"index.html"
    end

    get "/assets/js/ws.js" do
      content_type :js
      @scheme = ENV['RACK_ENV'] == "production" ? "wss://" : "ws://"
      erb :"application.js"
    end
  end
end
