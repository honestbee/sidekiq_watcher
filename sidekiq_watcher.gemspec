Gem::Specification.new do |s|
  s.name        = 'sidekiq_watcher'
  s.version     = '0.1.2'
  s.date        = '2018-11-15'
  s.description = "a gem"
  s.summary     = "This is an example!"
  s.authors     = ["Lin-Yao Li"]
  s.email       = 'linyao.li@honestbee.com'
  s.files       = ["lib/sidekiq_watcher.rb"]
  s.homepage    =
    'http://rubygems.org/gems/sidekiq_watcher'
  s.license     = 'MIT'

  s.add_development_dependency "bundler", "~> 1.16"
  s.add_development_dependency "rake", "~> 10.0"
  s.add_development_dependency "byebug"

  s.add_dependency "sidekiq"
  s.add_dependency "sinatra"
end
