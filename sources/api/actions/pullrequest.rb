require 'api/github'

module Action
  class PullrequestUpdatedFiles < API::Github::Action
    class UpdatedFilesResponse
      class File
        attr_accessor :name, :raw_url, :blob_url
        
        def initialize
          yield self
        end
      end
      
      attr_accessor :files
      
      def initialize
        @files = []
        yield self
      end
    end
    
    attr_accessor :pullrequest_id
    
    def initialize
      super do |a|
        a.method = :get
      end
      yield self if block_given?
    end
    
    def url
      "/repos/#{@owner}/#{@repository}/pulls/#{@pullrequest_id}/files"
    end
    
    def perform
      response = super
      UpdatedFilesResponse.new do |resp|
        response.each do |fd|
          resp.files << UpdatedFilesResponse::File.new do |f|
            f.name = fd["filename"]
            f.raw_url = fd["raw_url"]
            f.blob_url = fd["blob_url"]
          end
        end
      end
    end
  end
end
