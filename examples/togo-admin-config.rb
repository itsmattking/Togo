DataMapper::Logger.new(STDOUT, :debug)
DataMapper.setup(:default, "mysql://root:1nt3rfac3@localhost/togo_development")
DataMapper.auto_upgrade!
