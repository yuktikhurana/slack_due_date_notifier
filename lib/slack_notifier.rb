require_dependency 'issue'
require_relative '../app/jobs/slack_notifier_job'

module SlackNotifier
  def self.included(base)
    base.extend(ClassMethods)

    base.send(:include, InstanceMethods)

    base.class_eval do
      after_save :schedule_due_date_notification, if: [:assigned_to_id?, :due_date?, :due_date_changed?]
      delegate :login, to: :assigned_to, prefix: true, allow_nil: true
    end

  end

  module ClassMethods
  end

  module InstanceMethods

    private

    def schedule_due_date_notification
      delete_existing_notifications
      create_new_notifications
    end

    def delete_existing_notifications
      scheduled_jobs = Sidekiq::ScheduledSet.new
      existing_jobs = scheduled_jobs.select { |job| job.args[0]["arguments"][0]["_aj_globalid"] == self.to_global_id.to_s }
      existing_jobs.each { |job| job.delete }
    end

    def create_new_notifications
      before_days = Setting.plugin_slack_due_date_notifier['notification_days_before'].to_i
      after_days = Setting.plugin_slack_due_date_notifier['notification_days_after'].to_i
      SlackNotifierJob.set(wait_until: due_date.beginning_of_day).perform_later(self)
      SlackNotifierJob.set(wait_until: (due_date - before_days.days).beginning_of_day).perform_later(self) if before_days > 0
      SlackNotifierJob.set(wait_until: (due_date + after_days).beginning_of_day).perform_later(self) if after_days > 0
    end

  end

end

Issue.send(:include, SlackNotifier)
