class Category

  include DataMapper::Resource
  include Togo::DataMapper::Model
  
  property :id, Serial
  property :name, String, :length => 255
  property :positions, String
  
  list_properties :name

  has n, :blog_entries

  def to_s
    name
  end

end
