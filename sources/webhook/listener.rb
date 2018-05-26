require 'sinatra/base'
require 'json'

require 'webhook/handlers/pullrequest'

require 'utils/logger'


module Webhook
  class Listener < Sinatra::Base
    def self.run
      post '/' do
        dispatch request
        status 202 # ACK
      end
      
      run!
    end
    
    def dispatch(request)
      event = request.env["HTTP_X_GITHUB_EVENT"]
      payload = JSON.parse request.body.read
      Logger.info "Dispatch event '#{event}'"
      
      case event.to_sym
      when :pull_request
        Webhook::Handler::Pullrequest.process payload
      else
        Logger.error "Unknown webhook event: #{event}"
      end
    end
  end
end
