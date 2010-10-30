$TESTING=true
$:.push File.join(File.dirname(__FILE__), '..', '..', 'lib')
$:.push File.join(File.dirname(__FILE__), '..', '..', 'lib','togo')
%w(dm-core dm-migrations dm-serializer togo).each{|l| require l}
DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/model.db")

class BlogEntry
  include DataMapper::Resource
  include Togo::DataMapper::Model
  property :id, Serial
  property :title, String, :default => 'Hi'
  property :body, Text
  property :random_number, Integer
  belongs_to :category, :required => false
  has n, :tags, :through => Resource
end

class AnotherBlogEntry
  include DataMapper::Resource
  include Togo::DataMapper::Model
  property :id, Serial
  property :title, String
  property :body, Text
  property :date, DateTime

  belongs_to :category, :required => false
  belongs_to :another_category, :required => false
  has n, :tags, :through => Resource

  list_properties :date, :title, :category
  form_properties :body, :category, :date

  configure_property :body, :template => File.join(File.dirname(__FILE__),'custom_body.erb')

  configure_property :date, :label => "The Date"

end

class Category
  include DataMapper::Resource
  include Togo::DataMapper::Model
  property :id, Serial
  property :name, String
  has n, :another_blog_entries
  has n, :blog_entries
end

class AnotherCategory
  include DataMapper::Resource
  include Togo::DataMapper::Model
  property :id, Serial
  property :name, String
  has n, :another_blog_entries
end

class Tag
  include DataMapper::Resource
  include Togo::DataMapper::Model
  property :id, Serial
  property :name, String
  has n, :blog_entries, :through => Resource
  has n, :another_blog_entries, :through => Resource
end

DataMapper.auto_migrate!
