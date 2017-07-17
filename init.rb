require_dependency 'slack_notifier'

default_settings = ActionController::Parameters.new({
  slack_url: '',
  notification_days_before: 0,
  notification_days_after: 0,
  notification_date_column: 'due_date',
  slack_token: ''
})

Redmine::Plugin.register :slack_due_date_notifier do
  name 'Slack Due Date Notifier plugin'
  author 'Yukti Khurana'
  description 'This is a plugin to notify users about the due date'
  version '0.0.1'
  url 'http://example.com/path/to/plugin'
  author_url 'http://example.com/about'
  settings default: default_settings , partial: 'settings/notification_settings'
  menu :top_menu, :sidekiq, '/sidekiq'
end
