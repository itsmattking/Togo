$TESTING=true
$:.push File.join(File.dirname(__FILE__), '..', '..', 'lib')
$:.push File.join(File.dirname(__FILE__), '..', '..', 'lib','togo')
%w(togo togo/admin rack rack/test).each{|l| require l}
DataMapper.setup(:default, "mysql://root@localhost/togo_model_test")

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
  has n, :another_blog_entries
  has n, :blog_entries
end

def setup_browser
  Rack::Test::Session.new(Rack::MockSession.new(Togo::Admin.run!))
end
