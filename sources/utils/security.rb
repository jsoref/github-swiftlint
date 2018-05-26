require 'openssl'
require 'jwt'

module Security
  class Key
    def self.private_pem
      File.read "keys/swiftylinter.2018-05-25.private-key.pem"
    end
    
    def self.app_identifier
      File.read "keys/app_identifier.key"
    end
    
    def self.private_key
      OpenSSL::PKey::RSA.new(private_pem)
    end
    
    def self.jwt_token
      payload = {
        iat: Time.now.to_i,
        exp: Time.now.to_i + (10 * 60),
        iss: Integer(app_identifier.strip!)
      }
      
      JWT.encode(payload, private_key, "RS256")
    end
  end
end
