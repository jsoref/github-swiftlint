module Action
  class InstallationToken < API::Github::Action
    def initialize
      super do |a|
        a.method = :post
        a.headers = {:Accept => "application/vnd.github.machine-man-preview+json"}
        a.payload = {} # payload is required for post method.
      end
      yield self if block_given?
    end
    
    def url
      "installations/224421/access_tokens"
    end
  end
end
