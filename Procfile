release: rake db:migrate
web: bin/start-nginx bundle exec puma -C config/puma.rb
worker: bundle exec sidekiq -t 25 -c 1 -q default -q mailers
