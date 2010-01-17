class Location
  include DataMapper::Resource
  include Togo::DataMapper::Model
  property :id, Serial
  property :name, String
  property :pork, String
  property :midget, String
  property :fonk, String

  list_properties :fonk, :name, :midget
  form_properties :name, :pork, :midget
end
