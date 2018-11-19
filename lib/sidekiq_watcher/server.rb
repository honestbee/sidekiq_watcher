require "sinatra/base"
require_relative "./config"
require_relative './probe'
require_relative './notifier'

module SidekiqWatcher
  class Server < Sinatra::Base
    set :bind, '0.0.0.0'

    attr_reader :config

    class << self
      def start
        @config = SidekiqWatcher::Config.instance
        set :port, @config.port
      rescue => ex
        SidekiqWatcher.logger.error(ex)
        SidekiqWatcher.logger.info("Restarting in 3 seconds...")
        sleep 3
      ensure
        🔍
      end

      def 🔍
        Thread::abort_on_exception = true
        Thread.start do
          pb = SidekiqWatcher::Probe.new(@config)
          nt = SidekiqWatcher::Notifier.new(@config, pb.queues)

          while
            pb.probe
=begin
            unless status
              SidekiqWatcher.logger.warn("Can't find worker, re-check in #{@config.check_interval} seconds...")
              sleep @config.check_interval
              next
            end
=end
            if @config.statsd_client
              nt.queues = pb.queues
              nt.investigate
            end

            SidekiqWatcher.logger.info("Re-check in #{@config.check_interval} seconds...")
            sleep @config.check_interval
          end
        end

        Thread.start { run! }
      end
    end

    get '/' do
      if SidekiqWatcher.alive?
        status 200
        body "Alive!"
      else
        status 404
        body "Dead!"
      end
    end
  end
end
