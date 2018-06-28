require 'api/github'
require 'utils/tokens'

module Action
  class GetChecks < API::Github::Action
    def initialize
      super do |a|
        a.method = :get
        a.headers = {:Accept => "application/vnd.github.antiope-preview+json"}
      end
      yield self if block_given?
    end
    
    def url
      "/repos/#{@owner}/#{@repository}/check-runs"
    end
  end
  
  class CreateChecksRun < API::Github::Action
    class Output
      class Annotation
        attr_accessor :filename, :blob_href, :start_line, :end_line, :warning_level, :message
        
        def initialize
          yield self
        end
      end
      
      attr_accessor :title, :summary, :annotations
      attr_reader :payload
      
      def initialize
        @annotations = []
        yield self
        annotation_param = @annotations.map do |a|
          {
            :filename => a.filename,
            :blob_href => a.blob_href,
            :start_line => a.start_line,
            :end_line => a.end_line,
            :warning_level => a.warning_level,
            :message => a.message
          }
        end
        @payload = {
          :title => @title,
          :summary => @summary,
          :annotations => annotation_param
        }
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
        :status => "completed",
        :conclusion => @conclusion,
        :completed_at => @completed_at.to_s,
        :output => @output.payload
      }
    end
    
    def url
      "/repos/#{@owner}/#{@repository}/check-runs"
    end
  end
end
