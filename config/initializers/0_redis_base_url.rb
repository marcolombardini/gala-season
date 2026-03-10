# Strip any database number from REDIS_URL so each service can append its own.
# e.g. "redis://localhost:6379/10" -> "redis://localhost:6379"
REDIS_BASE_URL = ENV.fetch("REDIS_URL", "redis://localhost:6379").sub(%r{/\d+\z}, "")
