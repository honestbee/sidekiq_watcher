module SidekiqWatcher
  class Probe
    attr_reader :queues

    def initialize(config)
      @config = config
    end

    def probe
      sset = []
      Sidekiq::ProcessSet.new.each do |s|
        sset << s
      end

      this_worker = []
      SidekiqWatcher.logger.debug(sset)

      sset.each do |process|
        if process.instance_variable_get(:@attribs)["hostname"] == @config.hostname
          this_worker << process
        end
      end

      @queues = []
      this_worker.each{ |w| @queues << w.instance_variable_get(:@attribs)["queues"] }
      @queues = @queues.flatten.uniq

      @queues.each do |queue|
        job = Sidekiq::Queue.new(queue).first
        next unless job

        lat_threshold = @config.latency_dead_threshold[queue.to_sym]

        if lat_threshold
          if job.latency > lat_threshold
            SidekiqWatcher.logger.error("Latency of job in #{queue} is #{job.latency}, larger than threshold #{lat_threshold}, worker is possibly dead!")

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

      true
    end
  end
end
