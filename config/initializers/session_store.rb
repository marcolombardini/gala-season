Rails.application.config.session_store :redis_store,
                                       servers: ["#{ENV.fetch('REDIS_URL', 'redis://localhost:6379')}/1"],
                                       expire_after: 90.minutes,
                                       key: '_galaseason_session'
