require 'json'

require 'utils/logger'
require 'api/github'
require 'api/actions/installationtoken'

class Tokens
  class InstallationTokenResponse
    attr_accessor :token
    
    def initialize
      yield self
    end
    
    def to_s
      "token #{@token}"
    end
  end
  
  def self.request_installation_token(bearer)
    request = Action::InstallationToken.new do |req|
      req.headers[:Authorization] = bearer
    end
    
    request.perform
  end
end
