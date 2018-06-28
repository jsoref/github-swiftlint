require 'core/checksmanager'

module Core
  class PullRequestLintRequest
    attr_reader :action, :number, :state, :owner, :repository, :head_branch, :head_sha
    
    def initialize(pullrequest)
      @number = pullrequest.number
      @state = pullrequest.state
      @owner = pullrequest.owner
      @repository = pullrequest.repository
      @head_branch = pullrequest.head_branch
      @head_sha = pullrequest.head_sha
    end
  end
  
  module Linter
    def self.lint(request)
      case request
      when PullRequestLintRequest
        lint_new_pr request
      end
    end
    
    def self.lint_new_pr(request)
      check_ref = Core::ChecksManager.create_check_run request
      # TODO: run lint...
      sleep 5
      Core::ChecksManager.complete_check_run(check_ref, :success) do |output|
        output.title = "output title"
        output.summary = "output summary"
        
        # updated_files_response.files.each do |file|
        #   o.annotations << Action::Checks::CreateRun::Output::Annotation.new do |a|
        #     a.filename = file["filename"]
        #     a.blob_href = file["blob_url"]
        #     a.start_line = 1
        #     a.end_line = 1
        #     a.warning_level = "warning"
        #     a.message = "Unused import of 'Foundation'."
        #   end
        # end
      end
    end
  end
  
end
