sidekiq_redis = { url: "#{ENV.fetch('REDIS_URL', 'redis://localhost:6379')}/3" }

Sidekiq.configure_server do |config|
  config.redis = sidekiq_redis

  schedule_file = Rails.root.join('config/sidekiq_schedule.yml')
  if schedule_file.exist?
    schedule = YAML.load_file(schedule_file)
    if schedule.is_a?(Hash) && schedule.any?
      Sidekiq.schedule = schedule
      SidekiqScheduler::Scheduler.instance.reload_schedule!
    end
  end
end

Sidekiq.configure_client do |config|
  config.redis = sidekiq_redis
end
