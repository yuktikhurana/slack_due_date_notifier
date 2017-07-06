require_dependency 'issue'
require_relative '../app/jobs/slack_notifier_job'

module SlackNotifier
  def self.included(base)
    base.extend(ClassMethods)

    base.send(:include, InstanceMethods)

    base.class_eval do
      after_save :schedule_due_date_notification, if: [:due_date?, :due_date_changed?]
      delegate :login, to: :assigned_to, prefix: true, allow_nil: true
    end

  end

  module ClassMethods
  end

  module InstanceMethods

    def schedule_due_date_notification
      scheduled_jobs = Sidekiq::ScheduledSet.new
      existing_job = scheduled_jobs.find { |job| job.args[0]["arguments"][0]["_aj_globalid"] == self.to_global_id.to_s }
      existing_job.delete if existing_job
      SlackNotifierJob.set(wait_until: due_date.beginning_of_day).perform_later(self)
    end

  end

end

Issue.send(:include, SlackNotifier)
