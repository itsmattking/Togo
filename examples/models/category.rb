class Category

  include DataMapper::Resource
  include Togo::DataMapper::Model
  
  property :id, Serial
  property :name, String, :length => 255
  
  has n, :blog_entries

  list_properties :name, :blog_count

  def to_s
    name
  end

  def blog_count
    blog_entries.count
  end

end
