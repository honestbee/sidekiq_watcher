class TestWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'low'

  def perform(t)
    puts "sleep for #{t} seconds..."
    sleep t
  end
end
