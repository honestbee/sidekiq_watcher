module SidekiqWatcher
  class Config
    include Singleton

    attr_accessor :port,
                  :hostname,
                  :check_interval,
                  :latency_dead_threshold,
                  :latency_alert_threshold,
                  :pending_alert_threshold,
                  :statsd_client
  end
end
