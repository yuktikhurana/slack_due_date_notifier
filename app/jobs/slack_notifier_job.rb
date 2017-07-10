class SlackNotifierJob < ActiveJob::Base

  queue_as :default

  self.queue_adapter = :sidekiq

  def perform(*args)
    issue = args.first
    if issue.status.name == 'In Progress'
      response = HTTParty.post(Setting.plugin_slack_due_date_notifier['slack_url'], body: {
        message: I18n.translate(:due_date_message, title: issue.subject, due_date: issue.due_date),
        user_name: issue.assigned_to_login
      })
      parsed_response = response.parsed_response
      raise "#{ parsed_response['status'] } #{ parsed_response['error'] } -> #{ parsed_response['message'] }" unless response.success?
    end
  end

end
