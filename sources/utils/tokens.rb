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
    install_token_request = Action::InstallationToken.new do |req|
      req.headers[:Authorization] = bearer
    end
    
    response = API::Github.perform install_token_request
    InstallationTokenResponse.new do |rep|
      rep.token = response["token"]
    end
  end
end
