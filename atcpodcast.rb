require 'rubygems'
require 'bundler/setup'

require 'haml'
require 'sinatra'


# Flush log output immediately
$stdout.sync = true


get '/' do
    haml :index
end
