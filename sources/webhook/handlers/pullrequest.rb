require 'utils/logger'

module Webhook
  module Handler
    class Pullrequest
      class Response
        attr_accessor :action
        attr_accessor :number
        attr_accessor :state
        
        def initialize
          yield self
        end
      end
      
      def self.process(payload)
        response = parse_response payload
        
        case response.action
        when :opened, :edited
          opened response
        else
          Logger.error "Unknown pull request action: #{response.action}"
        end
      end
      
      def self.parse_response(payload)
        Response.new do |r|
          r.action = payload["action"].to_sym
          r.number = payload["pull_request"]["number"]
          r.state = payload["pull_request"]["state"].to_sym
        end
      end
      
      def self.opened(response)
        Logger.info "opened/edited ##{response.number}"
      end
    end
  end
end
