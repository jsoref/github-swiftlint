require 'api/github'

module Action
  class PullrequestUpdatedFiles < API::Github::Action
    class UpdatedFilesResponse
      attr_accessor :files
      
      def initialize
        @files = []
        yield self
      end
    end
    
    attr_accessor :number
    
    def initialize
      super do |a|
        a.method = :get
      end
      yield self if block_given?
    end
    
    def url
      "/repos/#{@owner}/#{@repository}/pulls/#{@number}/files"
    end
    
    def perform
      response = super
      UpdatedFilesResponse.new do |resp|
        resp.files = response
      end
    end
  end
end
