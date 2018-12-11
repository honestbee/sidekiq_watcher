module SidekiqWatcher
  class Config
    include Singleton

    attr_accessor :latency_dead_threshold,
                  :latency_alert_threshold,
                  :pending_alert_threshold,
                  :statsd_client

    attr_reader :port,
                :hostname,
                :check_interval

    def initialize
      @port = 7433
      @hostname = Socket.gethostname
      @check_interval = 5

      @latency_dead_threshold ||= {}
      @latency_alert_threshold ||= {}
      @pending_alert_threshold ||= {}
    end
  end
end
