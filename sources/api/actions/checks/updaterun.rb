require 'time'
require 'api/checks'
require 'utils/tokens'



module Action
  module Checks
    class UpdateRun < API::Github::Checks::ChecksAction
      
      attr_accessor :id, :name, :head_branch, :head_sha, :status, :started_at, :conclusion, :output
      attr_reader :payload
      
      def initialize
        super do |a|
          a.method = :patch
        end
        @payload = {}
        @status = "completed"
        yield self if block_given?
        
        @payload[:name] = @name if defined? @name
        @payload[:head_branch] = @head_branch if defined? @head_branch
        @payload[:head_sha] = @head_sha if defined? @head_sha
        @payload[:status] = @status if defined? @status
        @payload[:conclusion] = @conclusion if defined? @conclusion
        @payload[:output] = @output.payload if defined? @output
        
        @payload[:started_at] = defined? @started_at ? @started_at.to_s : Time.now.utc.iso8601
        @payload[:completed_at] = Time.now.utc.iso8601
      end
      
      def url
        "/repos/#{@owner}/#{@repository}/check-runs/#{@id}"
      end
      
      def perform
        super
      end
    end
  end
end
