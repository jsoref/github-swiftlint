require 'api/actions/checks/createrun'
require 'api/actions/checks/updaterun'

module Core
  module ChecksManager
    
    def self.create_check_run request
      createChecksRun = Action::Checks::CreateRun.new do |run|
        run.owner = request.owner
        run.repository = request.repository
        run.name = "syntax-linter"
        run.head_branch = request.head_branch
        run.head_sha = request.head_sha
        run.status = "in_progress"
      end
      response = createChecksRun.perform
    end
    
    def self.complete_check_run(check_ref, conclusion)
      action = Action::Checks::UpdateRun.new do |cr|
        cr.owner = check_ref.owner
        cr.repository = check_ref.repository
        cr.id = check_ref.id
        
        cr.conclusion = conclusion.to_s
        if block_given?
          output = API::Github::Checks::Output.new
          yield output
          cr.output = output
        end
      end
      response = action.perform
    end
    
  end
end
