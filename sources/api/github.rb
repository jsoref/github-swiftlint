require 'uri'
require 'json'
require 'rest-client'
require 'utils/security'
require 'utils/logger'

module API
  module Github
    class Action
      attr_accessor :repository, :owner, :method, :headers, :payload
      
      def initialize
        @headers = {}
        @payload = nil
        yield self
      end
      
      def perform
        Network.perform self
      end
    end
    
    class Network
      def self.base_url
        "https://api.github.com/"
      end
      
      def self.perform(action)
        action_url = URI.join(base_url, action.url).to_s
        headers = action.headers
        sender = RestClient.method(action.method)
        Logger.info "#{action.method} #{action_url}"
        headers.each do |header, value|
          Logger.info "Header #{header}: #{value}"
        end
        
        begin
          reponse = ""
          if action.payload != nil
            Logger.info "Payload: #{action.payload.to_json}"
            response = sender.call action_url, action.payload.to_json, headers
          else
            Logger.info "Payload: None"
            response = sender.call action_url, headers
          end
          Logger.info "Response:\n#{response}"
          JSON.parse response
        rescue RestClient::ExceptionWithResponse => e
          Logger.error e.response
          e.response
        end
      end
    end
  end
end
