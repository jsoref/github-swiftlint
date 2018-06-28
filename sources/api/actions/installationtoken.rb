module Action
  class InstallationToken < API::Github::Action
    class InstallationTokenResponse
      attr_accessor :token
      
      def initialize
        yield self
      end
      
      def to_s
        "token #{@token}"
      end
    end
    
    attr_accessor :installation_id
    
    def initialize
      super do |a|
        a.method = :post
        a.headers = {:Accept => "application/vnd.github.machine-man-preview+json"}
        a.payload = {} # payload is required for post method.
      end
      @installation_id = "224421"
      yield self if block_given?
    end
    
    def url
      "installations/#{@installation_id}/access_tokens"
    end
    
    def perform
      response = super
      
      InstallationTokenResponse.new do |resp|
        resp.token = response["token"]
      end
    end
  end
end
