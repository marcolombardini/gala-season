Rails.application.config.session_store :redis_store,
                                       servers: ["#{REDIS_BASE_URL}/1"],
                                       expire_after: 90.minutes,
                                       key: '_galaseason_session'
