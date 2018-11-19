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
        sleep 3
      ensure
        🛫
      end

      def 🛫
        Thread.start do
          while
            SidekiqWatcher::Probe.probe(@config)
            SidekiqWatcher.logger.info("probing!")

            if @config.statsd_client
              SidekiqWatcher::Notifier.investigate(@config, SidekiqWatcher::Probe.queues)
              SidekiqWatcher.logger.info("watching!")
            end

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
