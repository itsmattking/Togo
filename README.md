== Togo: Automatic Admin for Ruby ORMs

With just a few lines of code in your ORM classes, you get a full-featured content administration tool.

Quick example for DataMapper:

require 'togo'

class BlogEntry
  
  include DataMapper::Resource
  include Togo::DataMapper::Model
  
  property :id, Serial
  property :title, String
  property :body, Text
  property :published, Boolean

  list_properties :title, :published
  
  configure_property :published, :label => "Choose 'yes' to publish blog entry"

end

Go to your app with your models in a folder called "models", then run:

togo-admin

Current only works with DataMapper.
