require 'api/github'
require 'utils/tokens'

module API
  module Github
    module Checks
      class ChecksAction < API::Github::Action
        def initialize
          super do |a|
            a.headers = {:Accept => "application/vnd.github.antiope-preview+json"}
            
            bearer = "Bearer #{Security::Key.jwt_token}"
            token = Tokens.request_installation_token bearer
            self.headers[:Authorization] = token
            yield self
          end
        end
      end
      
      class Output
        class Annotation
          attr_accessor :filename, :blob_href, :start_line, :end_line, :warning_level, :message
          
          def initialize
            yield self
          end
        end
        
        attr_accessor :title, :summary, :annotations
        
        def initialize
          @annotations = []
          yield self if block_given?
        end
        
        def payload
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
          
          @_payload = {
            :title => @title,
            :summary => @summary,
            :annotations => annotation_param
          }
        end
      end
    end
  end
end
