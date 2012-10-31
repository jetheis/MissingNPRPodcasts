require 'net/http'

require 'builder'
require 'json'


class SafetyHash < Hash
    def [](y)
        result = super
        return result.nil? ? '' : result 
    end
end


class Podcast

    BASE_URL = 'http://api.npr.org/query?'
    DEFAULT_STORY_COUNT = 10

    def self.test_api_key apk_key
    end

    def initialize(args = {})
        @program_id = args[:program_id] or 2
        @api_key = args[:api_key]
        @hostname = args[:hostname] or 'missingprpodcasts.com'
        @story_count = args[:story_count] or DEFAULT_STORY_COUNT
        @copyright = args[:copyright] or 'Copyright 2012 NPR - For Personal Use Only' 
        @author = args[:author] or 'NPR: National Public Radio'
        @language = args[:language] or 'en'
    end

    def build_rss
        # Make the initial API call
        raw_json = self._get_program_json
        @program_json = raw_json['list']

        # RSS infrastructure
        xml = Builder::XmlMarkup.new
        xml.instruct! :xml, :version => '1.0', :encoding => 'UTF-8'

        # Generate final RSS
        xml.rss :version => '2.0', 'xmlns:itunes' => 'http://www.itunes.com/dtds/podcast-1.0.dtd' do
            xml.channel { |channel| self._populate_rss_channel channel }
        end
    end

    def _get_program_json
        request_args = URI.encode_www_form :id => @program_id,
                                           :fields => 'all',
                                           :dataType => 'story',
                                           :output => 'JSON',
                                           :numResults => @story_count,
                                           :apiKey => @api_key

        request_url = "#{BASE_URL}#{request_args}"

        response = Net::HTTP.get_response(URI.parse(request_url))
        return JSON.parse response.body, :object_class => SafetyHash
    end

    def _populate_rss_channel channel

        def program_property(prop)
            return @program_json[prop]['$text']
        end

        # General RSS metadata
        channel.title program_property('title')
        channel.link @program_json['link'][1]['$text'] if @program_json['link'] and @program_json['link'][1]
        channel.description program_property('teaser')
        channel.language @language
        channel.copyright @copyright

        # iTunes-specific metadata
        channel.itunes :subtitle, program_property('miniTeaser')
        channel.itunes :author, @author
        channel.itunes :summary, program_property('teaser')
        channel.itunes :image, {:href => "http://#{@hostname}/atc_logo_600.jpg"}
        channel.itunes :owner do |owner|
            owner.itunes :name, 'NPR: National Public Radio'
        end

        # Images
        channel.image do |image|
            image.url "http://#{@hostname}/atc_logo_75.jpg"
            image.title program_property('title')
            image.link @program_json['link'][1]['$text'] if @program_json['link'] and @program_json['link'][1]
        end

        # Individual stories
        @program_json['story'].each do |story_json|
            _populate_rss_story channel, story_json
        end
    end

    def _populate_rss_story channel, story_json
        # Check to see if this is an audio story before making an item for it
        begin
            m3u_url = story_json['audio'][0]['format']['mp3'][0]['$text']
        rescue
            return # Bail if there's no audio
        end

        # Find appropriate story URL
        story_url = ''
        story_json['link'].each { |link_json| story_url = link_json['$text'] if link_json['type'] == 'html' }

        # Skip if there isn't a link for this story
        puts story_url
        return if story_url.empty?

        # Go find the actual audio URL (separate web request)
        begin
            m3u_content = Net::HTTP.get_response(URI.parse(m3u_url)).body
            audio_url = m3u_content.split(/\s/)[0]
        rescue
            return # Bail if there's an error
        end

        channel.item do |story|
            story.title story_json['title']['$text']
            story.description story_json['miniTeaser']['$text'].gsub(%r{</?[^>]+?>}, '')
            story.link story_url
            story.guid story_url
            story.itunes :subtitle, story_json['miniTeaser']['$text'].gsub(%r{</?[^>]+?>}, '')
            story.itunes :summary, story_json['teaser']['$text'].gsub(%r{</?[^>]+?>}, '')
            story.itunes :explicit, 'no' # assumed
            story.itunes :image, {:href => "http://#{@hostname}/atc_logo_600.jpg"}
            story.enclosure :url => audio_url, :type => 'audio/mpeg'
            story.itunes :duration, story_json['audio'][0]['duration']['$text']
            story.pubDate story_json['pubDate']['$text']
            story.itunes :keywords

            ## Optional thumbnail image
            #if story_json.has_key? 'thumbnail' and story_json['thumbnail'].has_key? 'large'
            #    story.itunes :image, {:href => story_json['thumbnail']['large']['$text']}
            #end

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