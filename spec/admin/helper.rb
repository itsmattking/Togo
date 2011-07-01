$TESTING=true
$:.unshift File.join(File.dirname(__FILE__), '..', '..', 'lib')
$:.unshift File.join(File.dirname(__FILE__), '..', '..', 'lib','togo')
$:.unshift File.join(File.dirname(__FILE__), '..', '..', 'lib','togo','admin')
%w(do_sqlite3 togo togo/admin rack rack/test dm-core dm-serializer dm-migrations).each{|l| require l}
DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/admin.db")

class BlogEntry
  include DataMapper::Resource
  include Togo::DataMapper::Model
  property :id, Serial
  property :title, String, :default => 'Hi'
  property :body, Text
  belongs_to :category, :required => false
end

class Category
  include DataMapper::Resource
  include Togo::DataMapper::Model
  property :id, Serial
  property :name, String
  has n, :blog_entries
end

class User
  include DataMapper::Resource
  property :id, Serial
  property :username, String
  property :password, String

  attr_accessor :authenticated

  def authenticated?
    authenticated || false
  end

  def self.authenticate(username, password)
    if username == 'test' and password == 'test'
      u = new(:username => username, :password => password)
      u.authenticated = true
      u
    else
      nil
    end
  end
end

DataMapper.auto_migrate!

def setup_browser
  Rack::Test::Session.new(Rack::MockSession.new(Togo::Admin.run!))
end

