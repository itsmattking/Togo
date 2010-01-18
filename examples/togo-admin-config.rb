DataMapper::Logger.new(STDOUT, :debug)
DataMapper.setup(:default, "mysql://root@localhost/togo_development")
DataMapper.auto_upgrade!
