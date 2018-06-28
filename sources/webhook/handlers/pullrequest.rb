require 'time'
require 'utils/logger'

require 'api/github'
require 'api/actions/pullrequest'
require 'api/actions/checks'

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
          r.head_branch = payload["pull_request"]["head"]["ref"]
          r.head_sha = payload["pull_request"]["head"]["sha"]
        end
      end
      
      def self.opened(response)
        Logger.info "opened/edited ##{response.number}"
        
        action = Action::PullrequestUpdatedFiles.new do |pr|
          pr.number = response.number
          pr.owner = response.owner
          pr.repository = response.repository
        end
        
        updated_files = API::Github.perform action
        
        
        createChecksRun = Action::CreateChecksRun.new do |run|
          run.owner = response.owner
          run.repository = response.repository
          run.name = "Code Linter"
          run.head_branch = response.head_branch
          run.head_sha = response.head_sha
          run.status = "completed"
          run.conclusion = "action_required"
          run.completed_at = Time.now.utc.iso8601
          run.output = Action::CreateChecksRun::Output.new do |o|
            o.title = "output title"
            o.summary = "output summary"
            
            updated_files.each do |file|
              o.annotations << Action::CreateChecksRun::Output::Annotation.new do |a|
                a.filename = file["filename"]
                a.blob_href = file["blob_url"]
                a.start_line = 1
                a.end_line = 1
                a.warning_level = "warning"
                a.message = "Unused import of 'Foundation'."
              end
            end
          end
        end
        
        response = API::Github.perform createChecksRun
      end
    end
  end
end
