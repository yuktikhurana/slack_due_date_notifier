class SlackNotifierJob < ActiveJob::Base

  queue_as :default

  self.queue_adapter = :sidekiq

  def perform(*args)
    issue = args.first
    res = HTTParty.post(ENV['SLACK_URL'], body: {
      message: I18n.translate(:due_date_message),
      user_name: issue.assigned_to_login
    })
  end

end
