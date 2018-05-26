require 'utils/logger'

require 'api/github'
require 'api/actions/pullrequest'

module Webhook
  module Handler
    class Pullrequest
      class Response
        attr_accessor :action, :number, :state, :repository, :owner
        
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
          r.repository = payload["repository"]["name"]
          r.owner = payload["repository"]["owner"]["login"]
        end
      end
      
      def self.opened(response)
        Logger.info "opened/edited ##{response.number}"
        
        action = Action::PullrequestUpdatedFiles.new do |pr|
          pr.number = response.number
          pr.owner = response.owner
          pr.repository = response.repository
        end
        
        puts API::Github.perform action
      end
    end
  end
end
