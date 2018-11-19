module SidekiqWatcher
  class Probe
    attr_reader :worker, :queues

    def initialize(config)
      @config = config
    end

    def probe
      sset = []
      Sidekiq::ProcessSet.new.each do |s|
        sset << s
      end

      this_worker = nil
      sset.each do |process|
        if process.instance_variable_get(:@attribs)["hostname"] == @config.hostname
          this_worker = process
          break
        end
      end

      return unless this_worker

      @worker = this_worker
      @queues = this_worker.instance_variable_get(:@attribs)["queues"]

      @queues.each do |queue|
        job = Sidekiq::Queue.new(queue).first
        next unless job

        lat_threshold = @config.latency_dead_threshold[queue.to_sym]

        if lat_threshold
          if job.latency > @config.latency_dead_threshold[queue.to_sym]
            SidekiqWatcher.logger.error("Latency of job in #{queue} is too high, worker is possibly dead!")

            if @config.statsd_client
              @config.statsd_client.timing('sidekiq.latency.dead', job.latency, tags: ["queue:#{queue}"])
            end

            SidekiqWatcher.dead!
          else
            SidekiqWatcher.logger.info("Latency check: queue #{queue} is fine.")
            SidekiqWatcher.alive!
          end
        end
      end
    end
  end
end
