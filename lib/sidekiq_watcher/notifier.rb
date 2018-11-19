# Send notification to datadog (or other services).
module SidekiqWatcher
  class Notifier
    attr_writer :queues

    def initialize(config, queues)
      @config = config
      @queues = queues
    end

    def investigate
      latencies = {}
      pending = {}

      @queues.each do |queue|
        lat_threshold = @config.latency_alert_threshold[queue.to_sym]
        lt = Sidekiq::Queue.new(queue).latency
        latencies[queue] = lt if lat_threshold && lt > lat_threshold

        pending_threshold = @config.pending_alert_threshold[queue.to_sym]
        sz = Sidekiq::Queue.new(queue).size
        pending[queue] = sz if pending_threshold && sz > pending_threshold
      end

      unless latencies.empty? && pending.empty?
        logger.warn("Liveness check: Reached alert threashold.")
        logger.warn("Latency: #{latencies}")
        logger.warn("Pending: #{pending}")

        logger.info("Liveness check: Notify datadog.")
        notify_datadog(latencies, pending)
      end
    end

    private

    def logger
      SidekiqWatcher.logger
    end

    def notify_datadog(latencies, pending)
      statsd_client = @config.statsd_client
      return unless statsd_client

      latencies.each do |q, lt|
        statsd_client.timing('sidekiq.latency.alert', lt, tags: ["queue:#{q}"])
      end

      pending.each do |q, sz|
        statsd_client.timing('sidekiq.pending.alert', sz, tags: ["queue:#{q}"])
      end
    end

    def notify_bugsnag(latencies, pending)
      raise NotImplementedError
    end

    def notify_slack(latencies, pending)
      raise NotImplementedError
    end
  end
end
