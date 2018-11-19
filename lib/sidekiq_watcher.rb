require 'sidekiq'
require 'singleton'
require 'sidekiq_watcher/config'
require 'sidekiq_watcher/server'
require 'sidekiq_watcher/status'

module SidekiqWatcher
  def self.start
    Sidekiq.configure_server do |config|
      config.on(:startup) do
        SidekiqWatcher.tap do |sa|
          sa::Server.start
          alive!
          logger.info("sidekiq watch is boot up!")
        end
      end
    end
  end

  def self.setup
    yield(config)
  end

  def self.config
    @config ||= SidekiqWatcher::Config.instance
  end

  def self.logger
    Sidekiq::Logging.logger
  end

  def self.alive?
    status = redis.get(key)
    if status.to_i >= Status::DEFAULT
      return true
    else
      return false
    end
  end

  def self.alive!
    redis.set(key, Status::ALIVE)
  end

  def self.dead!
    redis.set(key, Status::DEAD)
  end

  def self.alert!
    redis.set(key, Status::ALERT)
  end

  def self.redis
    Sidekiq.redis { |r| r }
  end

  def self.key
    @timestamp_key ||= Time.now.to_f % 1
    "#{config.hostname}-#{@timestamp_key}-sidekiq-watcher"
  end
end

SidekiqWatcher.start unless ENV['DISABLE_SIDEKIQ_WATCHER']
