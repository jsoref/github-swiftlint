require 'api/github'

module Action
  class PullrequestUpdatedFiles < API::Github::Action
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
  end
end
