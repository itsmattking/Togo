class Location
  include DataMapper::Resource
  include Togo::DataMapper::Model
  property :id, Serial
  property :name, String
end
