class BlogEntry

  include DataMapper::Resource
  include Togo::DataMapper::Model

  property :id, Serial
  property :title, String, :length => 255
  property :date, DateTime, :default => DateTime.now
  property :body, Text
  property :tags, String, :length => 255
  property :enabled, Boolean, :default => false
  property :category_id, Integer

  belongs_to :category
  has n, :locations, :through => Resource

  list_properties :title, :date
  form_properties :title, :date, :body, :tags, :category, :locations, :enabled

  configure_property :title, :label => "The Title"
  configure_property :body, :template => File.join(SITE_ROOT, 'body.erb')

  def to_s
    title
  end

end
