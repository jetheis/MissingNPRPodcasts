require 'rubygems'
require 'bundler/setup'

require 'haml'
require 'rack-google-analytics'
require 'sinatra'
require 'sinatra/assetpack'

require './app/podcast'


STORY_COUNT = 30

set :root, File.dirname(__FILE__)

use Rack::GoogleAnalytics, :tracker => 'UA-36111667-1',
                           :multiple => true,
                           :domain => 'missingnprpodcasts.com'

assets {
    serve '/js', from: 'js'
    serve '/css', from: 'css'

    js :app, '/js/app.js', ['/js/missingnprpodcasts.js']
    css :app, '/css/app.css', ['/css/missingnprpodcasts.css']

    js_compression :uglify, { :toplevel => true }
}

get '/' do
    @base_url = request.base_url
    haml :index
end

get '/testapikey' do
    api_key = params[:key]

    content_type 'text/json'
    Podcast.test_api_key api_key
end

get '/podcasts/weekendsaturday' do
    podcast = Podcast.new :program_id => 7,
                          :api_key => params[:key],
                          :story_count => STORY_COUNT

    content_type 'text/xml'
    podcast.build_rss
end

get '/podcasts/weekendsunday' do
    podcast = Podcast.new :program_id => 10,
                          :api_key => params[:key],
                          :story_count => STORY_COUNT

    content_type 'text/xml'
    podcast.build_rss
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
