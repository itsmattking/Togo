class BlogEntry

  include DataMapper::Resource
  include Togo::DataMapper::Model

  property :id, Serial
  property :title, String, :length => 255
  property :date, DateTime, :default => DateTime.now
  property :body, Text
  property :enabled, Boolean, :default => false

  belongs_to :category, :required => false

  list_properties :title, :category, :date, :enabled
  form_properties :title, :category, :date, :body, :enabled

  configure_property :title, :label => "The Title"
end
