SITE_ROOT = File.dirname(File.expand_path(__FILE__))
$:.push(SITE_ROOT+'/../lib')
$:.push(SITE_ROOT+'/../lib/togo')
%w(dm-core togo).each{|l| require l}
Dir.glob(File.join(SITE_ROOT,'models','*.rb')).each{|f| require f}
DataMapper::Logger.new(STDOUT, :debug)
DataMapper.setup(:default, "mysql://root@localhost/togo_development")
DataMapper.auto_upgrade!
