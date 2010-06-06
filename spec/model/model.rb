require File.dirname(__FILE__) + '/helper'

describe "Togo Datamapper Model" do

  it "should have all properties in list and form properties by default" do
    list_props = BlogEntry.list_properties.map(&:name)
    form_props = BlogEntry.form_properties.map(&:name)
    list_props.should include :title
    list_props.should include :body
    list_props.should include :category
    form_props.should include :title
    form_props.should include :body
    form_props.should include :category
  end

  it "should hide list and form properties not set" do
    list_props = AnotherBlogEntry.list_properties.map(&:name)
    form_props = AnotherBlogEntry.form_properties.map(&:name)
    AnotherBlogEntry.send(:shown_properties).map(&:name).should == [:title, :body, :date, :category, :another_category]
    list_props.should include :title
    list_props.should include :category
    list_props.should_not include :body
    list_props.should_not include :another_category
    form_props.should include :body
    form_props.should include :category
    form_props.should_not include :title
    form_props.should_not include :another_category
  end

  it "should order list and form properties as requested" do
    AnotherBlogEntry.send(:shown_properties).map(&:name).should == [:title, :body, :date, :category, :another_category]
    AnotherBlogEntry.list_properties.map(&:name).should == [:date, :title, :category]
    AnotherBlogEntry.form_properties.map(&:name).should == [:body, :category, :date]
  end

  it "should create content" do
    BlogEntry.create_content!(:title => "Blog Title 1", :body => "Hi")
    BlogEntry.first(:title => "Blog Title 1").should_not be_nil
  end

  it "should update content" do
    BlogEntry.create_content!(:title => "Blog Title 2", :body => "Hi")
    b = BlogEntry.first(:title => "Blog Title 2")
    b.should_not be_nil
    b.body.should == 'Hi'
    BlogEntry.update_content!(b.id,:body => 'Hi There')
    BlogEntry.first(:title => "Blog Title 2").body.should == 'Hi There'
  end

  it "should render form template with content" do
    b = BlogEntry.first
    out = BlogEntry.form_for(BlogEntry.form_properties.first, b)
    out.should =~ Regexp.new("label for=\"#{BlogEntry.form_properties.first.name}\"")
    out.should =~ Regexp.new("input type=\"text\".*?value=\"#{b.title}\"")
  end

  it "should set custom label for property" do
    b = AnotherBlogEntry.create(:title => 'Something Something', :body => 'hi')
    prop = AnotherBlogEntry.form_properties.select{|f| f.name == :date}.first
    out = AnotherBlogEntry.form_for(prop, b)
    out.should =~ Regexp.new("label for=\"#{prop.name}\">#{AnotherBlogEntry.property_options[:date][:label]}</label>")
  end

  it "should render form template with default value on new content" do
    b = BlogEntry.new
    out = BlogEntry.form_for(BlogEntry.form_properties.first, b)
    out.should =~ Regexp.new("input type=\"text\".*?value=\"Hi\"")
  end    

  it "should render custom form template with content" do
    AnotherBlogEntry.create_content!(:title => 'Another Blog Title 1', :body => 'Hi')
    b = AnotherBlogEntry.first
    out = AnotherBlogEntry.form_for(BlogEntry.form_properties[1], b)
    out.should =~ /<h1>Custom Body<\/h1>/
    out.should =~ Regexp.new("label for=\"#{BlogEntry.form_properties[1].name}\"")
    out.should =~ Regexp.new("<textarea.*?>#{b.body}</textarea>")
  end

  it "should list a relationship in list and form properties" do
    BlogEntry.send(:shown_properties).map(&:name).should include :category
    BlogEntry.form_properties.map(&:name).should include :category
    BlogEntry.list_properties.map(&:name).should include :category
    BlogEntry.form_properties.select{|f| f.name == :category}.first.should be_a ::DataMapper::Associations::ManyToOne::Relationship
    BlogEntry.list_properties.select{|f| f.name == :category}.first.should be_a ::DataMapper::Associations::ManyToOne::Relationship
  end

  it "should not include foreign keys in properties" do
    BlogEntry.send(:shown_properties).map(&:name).should_not include :category_id
    BlogEntry.form_properties.map(&:name).should_not include :category_id
    BlogEntry.list_properties.map(&:name).should_not include :category_id
  end

  it "should include display value and foreign key in belongs to template" do
    b = AnotherBlogEntry.first
    b.category = Category.create(:name => 'blah')
    b.save
    out = AnotherBlogEntry.form_for(BlogEntry.form_properties.select{|f| f.name == :category}.first, b)
    out.should =~ Regexp.new("<input type=\"text\".*?value=\"#{b.category}\"")
    out.should =~ Regexp.new("<input type=\"hidden\".*?value=\"#{b.category.id}\"")
  end

  it "should display humanized and pluralized name" do
    BlogEntry.display_name.should == 'Blog Entries'
    Category.display_name.should == 'Categories'
  end

  it "should delete an item" do
    @blog_entry = BlogEntry.create(:title => 'test 1', :body => 'body')
    @blog_entry.id.should_not be_nil
    BlogEntry.delete_content(@blog_entry)
    BlogEntry.first(:id => @blog_entry.id).should be_nil
  end
end
