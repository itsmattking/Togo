class Location
  include DataMapper::Resource
  include Togo::DataMapper::Model
  property :id, Serial
  property :name, String
  property :pork, String
  property :fonk, String

  list_properties :name, :fonk
end
