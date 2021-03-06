# sidekiq_watcher
This gem watches the status of sidekiq workers. But please understand it is completely different from https://github.com/arturictus/sidekiq_alive/, which is designed to monitor the health of sidekiq workers.
The purpose of this project, is to monitor the pending jobs and latency of specific queues. If it exceeds the threshold, it sends an alert to a monitor tool(at this moment only datadog).

# Usage
### Example
```ruby
SidekiqWatcher.setup do |config|
  config.latency_dead_threshold = {
      low: 5,
      image-uplaoder: 100,
      high: 10
  }
  config.latency_alert_threshold = {low: 2}
  config.pending_alert_threshold = {low: 10}
  config.statsd_client = Statsd.client
end
```

### Configurable
Parameters | description | usage |
-----------|------|-----|
`latency_dead_threshold` | specify the maximum accepted latency of a queue, reaching this value will result in the termination of worker. Queues which are not specified will be ignored.
`latency_alert_threshold` | specify the latency of a queue that is alerting, reaching this value will send notification. Queues which are not specified will be ignored.
`pending_alert_threshold` | specify the amount of pending jobs in a queue, reaching this value will send notification. Queues which are not specified will be ignored.
`statsd_client` | set with datadog client if you wish to send metrics to datadog dashboard.
