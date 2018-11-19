module SidekiqWatcher
  class Probe
    attr_reader :worker, :queues

    def self.probe(config)
      sset = []
      Sidekiq::ProcessSet.new.each do |s|
        sset << s
      end

      this_worker = nil
      sset.each do |s|
        if s.instance_variable_get(:@attribs)["hostname"] == config.hostname
          this_worker = s
          break
        end
      end

      return unless this_worker

      @worker = this_worker
      @queues = this_worker.instance_variable_get(:@attribs)["queues"]

      @queues.each do |queue|
        job = Sidekiq::Queue.new(queue).first
        next unless job

        if job.latency > config.latency_dead_threshold[queue.to_sym]
          puts 'dead!'
          # TODO
          # notify datadog
          SidekiqWatcher.dead!
        end
      end
    end
  end
end
