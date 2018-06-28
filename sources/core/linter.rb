require 'open-uri'

require 'core/checksmanager'
require 'api/actions/pullrequest'
require 'utils/logger'

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
      
      begin
        updated_files = prepare_updated_files request
        
        annotations = run_lint updated_files.files
        conclusion = annotations.count > 0 ? :failure : :success
        
        Core::ChecksManager.complete_check_run(check_ref, conclusion) do |output|
          output.title = ""
          output.summary = ""
          
          output.annotations = annotations.first(50)
        end
      rescue => e
        Logger.critical e
        
        # Cancel current check run
        Core::ChecksManager.complete_check_run(check_ref, "cancelled") do |output|
          output.title = "Critical error occured"
          output.summary = "An exception was raised during the verifing process. The lint job won't work until fix."
        end
      end
    end
    
    def self.prepare_updated_files(pullrequest)
      request = Action::PullrequestUpdatedFiles.new do |r|
        r.repository = pullrequest.repository
        r.owner = pullrequest.owner
        r.pullrequest_id = pullrequest.number
      end
      response = request.perform
      
      # cleanup linter directory
      Dir.foreach("lintfiles") { |f| fn = File.delete(File.join("lintfiles", f)) if f != "." && f != ".." }
      
      response.files.select { |f| File.extname(f.name) == ".swift" }.each do |f|
        open("lintfiles/#{File.basename(f.name)}", 'wb') do |fd|
          fd << open(f.raw_url).read
        end
      end
      response
    end
    
    def self.run_lint(files_ref)
      lint_result = `swiftlint --path lintfiles --reporter csv`
      lint_result.each_line.select { |line| line.start_with? "/" }.map do |line|
        descriptor = line.split(",").map { |l| l.strip }
        
        
        filename = File.basename descriptor[0]
        line = descriptor[1]
        level = warning_level descriptor[3]
        issue_description = descriptor[4] + " " + descriptor[5]
        
        begin
          API::Github::Checks::Output::Annotation.new do |a|
            related_ref = files_ref.detect { |f| File.basename(f.name) == filename }
            
            a.filename = related_ref.name
            a.start_line = Integer(line)
            a.end_line = Integer(line)
            a.warning_level = level
            a.message = issue_description
            a.blob_href = related_ref.blob_url
          end
        rescue => e
          Logger.critical e
        end
      end
    end
    
    def self.warning_level(warning)
      case warning
      when "Warning"
        return "warning"
      when "Error"
        return "failure"
      end
      "notice"
    end
  end
  
end
