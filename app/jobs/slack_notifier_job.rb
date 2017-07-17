class SlackNotifierJob < ActiveJob::Base

  queue_as :default

  self.queue_adapter = :sidekiq

  def perform(*args)
    issue = args.first
    if issue.status.name == 'Resolved'
      send_message_to(issue, issue.author_login)
      send_message_to(issue, issue.assigned_to_login)
    end
  end

  private

  def send_message_to(issue, user_name)
    plugin_settings = Setting.find_by_name('plugin_slack_due_date_notifier').value
    response = HTTParty.post(plugin_settings['slack_url'], body: {
      message: I18n.translate(:due_date_message, title: issue.subject, due_date: issue.due_date),
      userName: user_name,
      token: plugin_settings['slack_token']
    })
    parsed_response = response.parsed_response
    raise "#{ parsed_response['status'] } #{ parsed_response['error'] } -> #{ parsed_response['message'] }" unless response.success?
  end

end
