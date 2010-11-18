class Category

  include DataMapper::Resource
  include Togo::DataMapper::Model
  
  property :id, Serial
  property :name, String, :length => 255
  
  has n, :blog_entries

  list_properties :name, :blog_entries

  def to_s
    name
  end

end
