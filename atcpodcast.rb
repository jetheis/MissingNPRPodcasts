require 'rubygems'
require 'bundler/setup'

require 'net/http'

require 'builder'
require 'haml'
require 'json'
require 'sinatra'


# Flush log output immediately
$stdout.sync = true

$num_records = ENV['ATC_STORY_COUNT'].to_i
$num_records = 20 if $num_records == 0

# NPR API request
$request_url = "http://api.npr.org/query?id=2&fields=all&dateType=story&output=JSON&numResults=#{$num_records}&apiKey=#{ENV['NPR_API_KEY']}"
puts $request_url

get '/' do
    @hostname = request.host
    if request.port != 80
        @hostname << ":#{request.port}"
    end

    haml :index
end

get '/podcast' do
    # Figure out the hostname
    hostname = request.host
    if request.port != 80
        hostname << ":#{request.port}"
    end

    # Set the content type of the response
    content_type 'text/xml'

    # Make web request and parse JSON response
    response = Net::HTTP.get_response(URI.parse($request_url))
    data = response.body
    result_json = JSON.parse(data)

    # Traverse JSON to root object
    program_json = result_json['list']

    # Set up XML document
    xml = Builder::XmlMarkup.new
    xml.instruct! :xml, :version => '1.0', :encoding => 'UTF-8'

    # Construct the feed
    xml.rss :version => '2.0', 'xmlns:itunes' => 'http://www.itunes.com/dtds/podcast-1.0.dtd' do
        xml.channel do |channel|
            # Channel metadata
            channel.title program_json['title']['$text']
            channel.link program_json['link'][1]['$text']
            channel.language 'en' # assumed
            channel.copyright 'Copyright 2012 NPR - For Personal Use Only' # assumed
            channel.itunes :subtitle, program_json['miniTeaser']['$text']
            channel.itunes :author, 'NPR: National Public Radio' # assumed
            channel.itunes :summary, program_json['teaser']['$text']
            channel.description program_json ['teaser']['$text']
            channel.itunes :image, {:href => "http://#{hostname}/atc_logo_600.jpg"}
            channel.image do |image|
                image.url "http://#{hostname}/atc_logo_75.jpg"
                image.link program_json['link'][1]['$text']
                image.title program_json['title']['$text']
            end
            channel.itunes :owner  do |owner|
                owner.itunes :name, 'NPR: National Public Radio'
            end

            # Construct story items
            program_json['story'].each do |story_json|

                # Check to see if this is an audio story before making an item for it
                begin
                    m3u_url = story_json['audio'][0]['format']['mp3'][0]['$text']
                rescue
                    next
                end

                # Find appropriate story URL
                story_url = ''
                story_json['link'].each do |link_json|
                    story_url = link_json['$text'] if link_json['type'] == 'html'
                end

                # Skip if there isn't a link for this story
                next if story_url.empty?

                # Go find the actual audio URL (separate web request)
                begin
                    m3u_content = Net::HTTP.get_response(URI.parse(m3u_url)).body
                    audio_url = m3u_content.split(/\s/)[0]
                rescue
                    next
                end

                xml.item do |story|
                    story.title story_json['title']['$text']
                    story.description story_json['miniTeaser']['$text'].gsub(%r{</?[^>]+?>}, '')
                    story.link story_url
                    story.guid story_url
                    story.itunes :subtitle, story_json['miniTeaser']['$text'].gsub(%r{</?[^>]+?>}, '')
                    story.itunes :summary, story_json['teaser']['$text'].gsub(%r{</?[^>]+?>}, '')
                    story.itunes :explicit, 'no' # assumed
                    story.enclosure :url => audio_url, :type => 'audio/mpeg'
                    story.itunes :duration, story_json['audio'][0]['duration']['$text']
                    story.pubDate story_json['pubDate']['$text']
                    story.itunes :keywords

                    # Optional thumbnail image
                    if story_json.has_key? 'thumbnail' and story_json['thumbnail'].has_key? 'large'
                        story.itunes :image, {:href => story_json['thumbnail']['large']['$text']}
                    end

                    # Construct author list before writing it (if there are authors)
                    if story_json.has_key? 'byline'
                        authors = []

                        story_json['byline'].each do |byline_json|
                            authors << byline_json['name']['$text']
                        end

                        story.itunes :author, authors.join(', ')
                    end
                end
            end
        end
    end
end
