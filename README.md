# sidekiq_watcher
Still in progress. This gem watches the status of sidekiq workers for Kubernetes and Datadog.

# Usage
In sidekiq config,
```ruby
SidekiqWatcher.setup do |config|
  config.port = 7433
  config.hostname = Socket.gethostname
  config.check_interval = 5
  config.latency_dead_threshold = {'low': 5}
  config.latency_alert_threshold = {'low': 2}
  config.pending_alert_threshold = {'low': 10}
  config.statsd_client = Statsd.client
end
```
