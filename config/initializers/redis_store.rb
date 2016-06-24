# http://jerodsanto.net/2013/01/configuring-redis-store-redis-rails-on-heroku/

redis_url = ENV["REDISCLOUD_URL"] || "redis://127.0.0.1:6379/wordhalo"
puts redis_url
Rails.application.config.cache_store = :redis_store, redis_url
Rails.application.config.session_store :redis_store, redis_server: redis_url
