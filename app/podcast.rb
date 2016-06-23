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

    BASE_URL = 'https://api.npr.org/query?'
    DEFAULT_STORY_COUNT = 10

    def self.test_api_key api_key
            request_args = URI.encode_www_form :id => 1,
                                               :fields => 'all',
                                               :dataType => 'story',
                                               :output => 'JSON',
                                               :numResults => 1,
                                               :apiKey => api_key

            request_url = "#{BASE_URL}#{request_args}"
            uri = URI.parse(request_url)
            http = Net::HTTP.new(uri.host, uri.port)
            http.use_ssl = true
            http.verify_mode = OpenSSL::SSL::VERIFY_NONE
            response = http.get(uri.request_uri)
            json = JSON.parse response.body, :object_class => SafetyHash

            return JSON.generate({ :validKey => json.key?('list') })
    end

    def initialize(args = {})
        @program_id = args[:program_id] or 2
        @api_key = args[:api_key]
        @story_count = args[:story_count] or DEFAULT_STORY_COUNT
        @copyright = "Copyright #{Date.today.year} NPR"
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
        uri = URI.parse(request_url)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        response = http.get(uri.request_uri)
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

        # NEW! Add image and ... podcast metadata
        channel.itunes :image, 'href="http://dudesbros.com/custom_npr_logo.png"/'

        # iTunes-specific metadata
        channel.itunes :subtitle, program_property('miniTeaser')
        channel.itunes :author, @author
        channel.itunes :summary, program_property('teaser')
        channel.itunes :owner do |owner|
            owner.itunes :name, 'NPR: National Public Radio'
        end

        # Individual stories
        @program_json['story'].each do |story_json|
            _populate_rss_story channel, story_json
        end
    end

    def _populate_rss_story channel, story_json
        # Check to see if this is an audio story before making an item for it
        begin
            # NEW! m3u_url = story_json['audio'][0]['format']['mp3'][0]['$text']
            # NEW! replacing the above mp3 playlist url with the below mp4 (m4a / AAC) url for better quality and file-size
            audio_url = story_json['audio'][0]['format']['mp4'][0]['$text']
        rescue
            return # Bail if there's no audio
        end

        # Find appropriate story URL
        story_url = ''
        story_json['link'].each { |link_json| story_url = link_json['$text'] if link_json['type'] == 'html' }

        # Skip if there isn't a link for this story
        return if story_url.empty?

        # NEW! Adding the short URL so we can use it somewhere to make sharing easier
        short_url = ''
        story_json['link'].each { |link_json| short_url = link_json['$text'] if link_json['type'] == 'short' }

        # NEW! This block is no longer necessary when using the mp4 url
        # Go find the actual audio URL (separate web request)
        # begin
        #     m3u_content = Net::HTTP.get_response(URI.parse(m3u_url)).body
        #     audio_url = m3u_content.split(/\s/)[0]
        # rescue
        #     return # Bail if there's an error
        # end

        # NEW! adding individual images for episodes...so excited!
        image_url = story_json['image'][0]['enlargement']['src']

        channel.item do |story|
            story.title story_json['title']['$text']
            story.link story_url
            story.guid story_url
            story.itunes :subtitle, story_json['miniTeaser']['$text'].gsub(%r{</?[^>]+?>}, '')
            story.itunes :summary, story_json['teaser']['$text'].gsub(%r{</?[^>]+?>}, '')
            story.itunes :explicit, 'no' # assumed
            story.itunes :duration, story_json['audio'][0]['duration']['$text']
            story.pubDate story_json['pubDate']['$text']
            story.itunes :keywords

            #NEW!
            story.enclosure :url => audio_url, :type => 'audio/m4a' # changed from mp3 to m4a (aka mp4 aka HE-AAC)
            story.itunes :image => image_url

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
