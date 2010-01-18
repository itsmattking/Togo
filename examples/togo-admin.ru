require 'togo'
require 'togo/admin'

# Togo Admin Configuration/Rackup File
# You should require any extras needed for your models here. You should also set up
# any database connections here that would be required to load your models.
#
# You can pass in a configuration hash to the run! method to alter options in Togo Admin.
# Available Configuration options:
#
# # :handler => YourHandlerClass
# Default: Togo Admin looks for Thin, Mongrel and Webrick Rack handlers in that order.
# You can pass in your own custom handler in as long as it conforms to the Rack handler specs.
#
# # :port => [Port Number]
# Default: 8080
#
# # :host => [IP]
# Default: '127.0.0.1'
#
# # :environment => [Environment Name]
# Default: :development
# Development will allow code reloading (e.g., you can modify models and have your changes
# show up without restarting togo-admin).

DataMapper::Logger.new(STDOUT, :debug)
DataMapper.setup(:default, "mysql://root@localhost/togo_development")
DataMapper.auto_upgrade!

config = {:port => 8081}
if Togo::Admin.config[:standalone]
  Togo::Admin.run!(config)
else
  run Togo::Admin.run!(config)
end
