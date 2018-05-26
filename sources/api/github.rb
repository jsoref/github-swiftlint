require 'uri'
require 'json'
require 'rest-client'
require 'utils/security'
require 'utils/logger'

module API
  class Github
    class Action
      attr_accessor :repository, :owner, :method, :headers, :payload
      
      def initialize
        @headers = {}
        yield self
      end
    end
    
    @base_url = "https://api.github.com/"
    
    class << self
      attr_reader :base_url
    end
    
    def self.perform(action)
      action_url = URI.join(@base_url, action.url).to_s
      headers = action.headers.merge authorization
      sender = RestClient.method(action.method)
      
      Logger.info "#{action.method} #{action_url}"
      headers.each do |header, value|
        Logger.info "Header #{header}: #{value}"
      end
      
      begin
        reponse = ""
        if defined?(action.payload) == true
          response = sender.call action_url, action.payload.to_json, headers
        else
          response = sender.call action_url, headers
        end
        JSON.parse response
      rescue RestClient::ExceptionWithResponse => e
        puts e.response
      end
    end
    
    def self.authorization
      {}
      # {:authorization => "Bearer #{Security::Key.jwt_token}"}
    end
  end
end
