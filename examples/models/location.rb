class Location
  include DataMapper::Resource
  include Togo::DataMapper::Model
  property :id, Serial
  property :name, String
  property :pork, String
  property :midget, String
  property :fonk, String
   
  has n, :blog_entries, :through => Resource

  list_properties :fonk, :name, :midget
  form_properties :name, :pork, :midget, :fonk, :blog_entries
end
