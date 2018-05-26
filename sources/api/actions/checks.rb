require 'api/github'

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
      "/repos/#{@owner}/#{@repository}/check-suites/1285797/check-runs"
    end
  end
end
