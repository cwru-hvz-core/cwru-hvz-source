worker_processes 2
timeout 30
preload_app true

APP_PATH = '/home/hvz/cwru-hvz-source'

working_directory APP_PATH

pid APP_PATH + '/tmp/pid/unicorn.pid'

listen APP_PATH + '/tmp/sockets/unicorn.sock'
listen 8080

before_fork do |server, worker|
  defined?(ActiveRecord::Base) && ActiveRecord::Base.connection.disconnect!
end

after_fork do |server, worker|
  defined?(ActiveRecord::Base) && ActiveRecord::Base.establish_connection
end
