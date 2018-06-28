require 'api/github'
require 'utils/tokens'

module Action
  module Checks
    class CreateRun < API::Github::Action
      
      class CreateChecksRunResponse
        attr_accessor :id, :repository, :owner
        
        def initialize
          yield self
        end
      end
      
      attr_accessor :name, :head_branch, :head_sha, :status, :conclusion, :completed_at, :output
      
      def initialize
        super do |a|
          a.method = :post
          a.headers = {:Accept => "application/vnd.github.antiope-preview+json"}
          
          bearer = "Bearer #{Security::Key.jwt_token}"
          token = Tokens.request_installation_token bearer
          self.headers[:Authorization] = token
        end
        yield self if block_given?
        @payload = {
          :name => @name,
          :head_branch => @head_branch,
          :head_sha => @head_sha,
          :status => @status
        }
        
        @payload[:conclusion] = @conclusion if defined? @conclusion
        @payload[:output] = @output.payload if defined? @output
        @payload[:completed_at] = @completed_at.to_s if defined? @completed_at
      end
      
      def url
        "/repos/#{@owner}/#{@repository}/check-runs"
      end
      
      def perform
        response = super
        CreateChecksRunResponse.new do |resp|
          resp.id = response["id"]
          resp.repository = @repository
          resp.owner = @owner
        end
      end
    end
  end
end
