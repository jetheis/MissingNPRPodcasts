require 'rubygems'
require 'bundler/setup'

require 'net/http'

require 'haml'
require 'json'
require 'sinatra'


# Flush log output immediately
$stdout.sync = true


get '/' do
    haml :index
end

get '/podcast' do
    request_url = "http://api.npr.org/query?id=2&fields=title,storyDate,audio&dateType=story&output=JSON&numResults=50&apiKey=#{ENV['NPR_API_KEY']}"
    puts request_url
    response = Net::HTTP.get_response(URI.parse(request_url))
    data = response.body
    result = JSON.parse(data)
    program = result['list']
    program['story'].each do |story|
        puts story['title']['$text']
    end

    'no error'
end
