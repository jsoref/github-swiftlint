require 'time'
require 'utils/logger'

require 'core/linter'

require 'api/github'
require 'api/actions/pullrequest'
require 'api/actions/checks/createrun'

module Webhook
  module Handler
    class Pullrequest
      class Response
        attr_accessor :action, :number, :state, :repository, :owner, :head_branch, :head_sha
        
        def initialize
          yield self
        end
      end
      
      def self.process(payload)
        lintRequest = parse_response payload
        Core::Linter.lint lintRequest
      end
      
      def self.parse_response(payload)
        response = Response.new do |r|
          r.action = payload["action"].to_sym
          r.number = payload["pull_request"]["number"]
          r.state = payload["pull_request"]["state"].to_sym
          r.repository = payload["repository"]["name"]
          r.owner = payload["repository"]["owner"]["login"]
          r.head_branch = payload["pull_request"]["head"]["ref"]
          r.head_sha = payload["pull_request"]["head"]["sha"]
        end
        
        Core::PullRequestLintRequest.new response
      end
    end
  end
end
