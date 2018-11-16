require "sinatra/base"
require_relative "./config"
require_relative './probe'
require_relative './notifier'

module SidekiqWatcher
  class Server < Sinatra::Base
    set :bind, '0.0.0.0'

    class << self
      def start
        set :port, SidekiqWatcher.config.port
        @config = SidekiqWatcher::Config.instance

        Thread.start do
          while
            SidekiqWatcher::Probe.probe(@config)
            puts "probing!"

            #SidekiqWatcher::Notifier.investigate(@config, SidekiqWatcher::Probe.queues)
            puts "watching!"

            sleep @config.check_interval
          end
        end

        Thread.start { run! }
      end

      def quit!
        super
        exit
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
