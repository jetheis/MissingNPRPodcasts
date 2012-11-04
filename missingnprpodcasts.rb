require 'rubygems'
require 'bundler/setup'

require 'haml'
require 'sinatra'

require './podcast'


STORY_COUNT = 20

get '/' do
    @base_url = request.base_url
    haml :index
end

get '/testapikey' do
    api_key = params[:key]

    content_type 'text/json'
    Podcast.test_api_key api_key
end

get '/podcasts/morningedition' do
    podcast = Podcast.new :program_id => 3,
                          :api_key => params[:key],
                          :story_count => STORY_COUNT

    content_type 'text/xml'
    podcast.build_rss
end

get '/podcasts/allthingsconsidered' do
    podcast = Podcast.new :program_id => 2,
                          :api_key => params[:key],
                          :story_count => STORY_COUNT

    content_type 'text/xml'
    podcast.build_rss
end