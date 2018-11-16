# Send notification to datadog (or other services).
module SidekiqWatcher
  class Notifier
    def self.investigate(config, queues)
      latencies = {}
      pending = {}

      queues.each do |queue|
        lt = Sidekiq::Queue.new(queue).latency
        latencies[queue] = lt if lt > config.latency_alert_threshold[queue.to_sym]

        sz = Sidekiq::Queue.new(queue).size
        pending[queue] = sz if sz > config.pending_alert_threshold[queue.to_sym]
      end

      notify_datadog(config, latencies, pending)
    end

    private

    def self.notify_datadog(config, latencies, pending)
      statsd_client = config.statsd_client
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
