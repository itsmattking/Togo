require File.dirname(__FILE__) + '/helper'

describe "Togo Datamapper Model" do

  it "should have all properties in list and form properties by default" do
    list_props = BlogEntry.get_list_properties.map(&:name)
    form_props = BlogEntry.get_form_properties.map(&:name)

    list_props.should include :title
    list_props.should include :body
    list_props.should include :category
    list_props.should include :random_number
    list_props.should include :tags

    form_props.should include :title
    form_props.should include :body
    form_props.should include :category
    form_props.should include :random_number
    form_props.should include :tags
  end

  it "should hide list and form properties not set" do
    list_props = AnotherBlogEntry.get_list_properties.map(&:name)
    form_props = AnotherBlogEntry.get_form_properties.map(&:name)
    AnotherBlogEntry.send(:shown_properties).map(&:name).should == [:title, :body, :date, :category, :another_category, :tags]
    list_props.should include :title
    list_props.should include :category
    list_props.should_not include :body
    list_props.should_not include :another_category
    list_props.should_not include :tags
    form_props.should include :body
    form_props.should include :category
    form_props.should_not include :title
    form_props.should_not include :another_category
  end

  it "should order list and form properties as requested" do
    AnotherBlogEntry.send(:shown_properties).map(&:name).should == [:title, :body, :date, :category, :another_category, :tags]
    AnotherBlogEntry.get_list_properties.map(&:name).should == [:date, :title, :category, :user_defined_method]
    AnotherBlogEntry.get_form_properties.map(&:name).should == [:body, :category, :date, :tags]
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

  it "should add related content on creation" do
    c = Category.create(:name => "Relationship Category Test")
    BlogEntry.create_content!(:title => "Blog Entry Relationship Test", :body => "Test", :related_category => c.id.to_s)
    b = BlogEntry.first(:title => "Blog Entry Relationship Test")
    b.should_not be_nil
    b.category.id.should == c.id
  end

  it "should add multiple related content on creation" do
    BlogEntry.create_content!(:title => "Blog Entry Relationship Test 2", :body => "Test")
    BlogEntry.create_content!(:title => "Blog Entry Relationship Test 3", :body => "Test")
    b1 = BlogEntry.first(:title => "Blog Entry Relationship Test 2")
    b2 = BlogEntry.first(:title => "Blog Entry Relationship Test 3")
    b1.should_not be_nil
    b2.should_not be_nil
    Category.create_content!(:name => "Relationship Category Test 2", :related_blog_entries => [b1.id,b2.id].join(','))
    c = Category.first(:name => "Relationship Category Test 2")
    c.blog_entries.map(&:id).should include(b1.id)
    c.blog_entries.map(&:id).should include(b2.id)
  end

  it "should not clear related content on 'unset' string" do
    c = Category.first(:name => "Relationship Category Test 2")
    c.blog_entries.size.should == 2
    Category.update_content!(c.id, :related_blog_entries => "unset")
    c = Category.first(:name => "Relationship Category Test 2")
    c.blog_entries.size.should == 2
  end

  it "should update related content" do
    BlogEntry.create_content!(:title => "Blog Entry Relationship Test 4")
    b1 = BlogEntry.first(:title => "Blog Entry Relationship Test 4")
    b2 = BlogEntry.first(:title => "Blog Entry Relationship Test 2")
    b3 = BlogEntry.first(:title => "Blog Entry Relationship Test 3")
    c = Category.first(:name => "Relationship Category Test 2")
    c.blog_entries.size.should == 2
    c.blog_entries.map(&:id).should include b2.id
    Category.update_content!(c.id, :related_blog_entries => [b1.id, b3.id].join(','))
    c = Category.first(:name => "Relationship Category Test 2")
    c.blog_entries.size.should == 2
    c.blog_entries.map(&:id).should_not include b2.id
    c.blog_entries.map(&:id).should include b3.id
  end

  it "should clear related content on empty string" do
    c = Category.first(:name => "Relationship Category Test 2")
    c.blog_entries.size.should == 2
    Category.update_content!(c.id, :related_blog_entries => "")
    c = Category.first(:name => "Relationship Category Test 2")
    c.blog_entries.size.should == 0
  end

  it "should render form template with content" do
    b = BlogEntry.first
    out = BlogEntry.form_for(BlogEntry.get_form_properties.first, b)
    out.should =~ Regexp.new("label for=\"#{BlogEntry.get_form_properties.first.name}\"")
    out.should =~ Regexp.new("input type=\"text\".*?value=\"#{b.title}\"")
  end

  it "should set custom label for property" do
    b = AnotherBlogEntry.create(:title => 'Something Something', :body => 'hi')
    prop = AnotherBlogEntry.get_form_properties.select{|f| f.name == :date}.first
    out = AnotherBlogEntry.form_for(prop, b)
    out.should =~ Regexp.new("label for=\"#{prop.name}\">#{AnotherBlogEntry.property_options[:date][:label]}</label>")
  end

  it "should render form template with default value on new content" do
    b = BlogEntry.new
    out = BlogEntry.form_for(BlogEntry.get_form_properties.first, b)
    out.should =~ Regexp.new("input type=\"text\".*?value=\"Hi\"")
  end    

  it "should render custom form template with content" do
    AnotherBlogEntry.create_content!(:title => 'Another Blog Title 1', :body => 'Hi')
    b = AnotherBlogEntry.first
    out = AnotherBlogEntry.form_for(BlogEntry.get_form_properties[1], b)
    out.should =~ /<h1>Custom Body<\/h1>/
    out.should =~ Regexp.new("label for=\"#{BlogEntry.get_form_properties[1].name}\"")
    out.should =~ Regexp.new("<textarea.*?>#{b.body}</textarea>")
  end

  it "should list a relationship in list and form properties" do
    BlogEntry.send(:shown_properties).map(&:name).should include :category
    BlogEntry.get_form_properties.map(&:name).should include :category
    BlogEntry.get_list_properties.map(&:name).should include :category
    BlogEntry.get_form_properties.select{|f| f.name == :category}.first.type.should == 'belongs_to'
    BlogEntry.get_list_properties.select{|f| f.name == :category}.first.type.should == 'belongs_to'
  end

  it "should not include foreign keys in properties" do
    BlogEntry.send(:shown_properties).map(&:name).should_not include :category_id
    BlogEntry.get_form_properties.map(&:name).should_not include :category_id
    BlogEntry.get_list_properties.map(&:name).should_not include :category_id
  end

  it "should choose correct template based on property" do
    BlogEntry.send(:type_from_property, BlogEntry.send(:shown_properties).find{|p| p.name == :title}).should == 'string'
    BlogEntry.send(:type_from_property, BlogEntry.send(:shown_properties).find{|p| p.name == :category}).should == 'belongs_to'
    BlogEntry.send(:type_from_property, BlogEntry.send(:shown_properties).find{|p| p.name == :tags}).should == 'many_to_many'
    Category.send(:type_from_property, Category.send(:shown_properties).find{|p| p.name == :blog_entries}).should == 'has_n'
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

  it "should search items" do
    @blog_entry1 = BlogEntry.create(:title => 'search test 1', :body => 'body')
    @blog_entry2 = BlogEntry.create(:title => 'search test 2', :body => 'body')
    @results = BlogEntry.search(:q => 'search test')
    @results.size.should == 2
    @results.map(&:title).should include 'search test 1'
    @results.map(&:title).should include 'search test 2'
    @results = BlogEntry.search(:q => 'non-search test')
    @results.size.should == 0
  end

  it "should page search items" do
    @results = BlogEntry.search(:q => 'search test', :limit => 1, :offset => 1)
    @results.size.should == 1
    @results.map(&:title).should_not include 'search test 1'
    @results.map(&:title).should include 'search test 2'
  end

  it "should not search non-text fields" do
    @blog_entry = BlogEntry.create(:title => 'search field test 1', :body => 'body', :random_number => 45678)
    @results = BlogEntry.search(:q => '45678')
    @results.size.should == 0
  end

  it "should be able to define instance methods as display options" do
    @blog_entry = AnotherBlogEntry.first
    AnotherBlogEntry.get_list_properties.map(&:name).should include :user_defined_method
    @blog_entry.send(AnotherBlogEntry.get_list_properties.find{|f| f.name == :user_defined_method}.name).should == "#{@blog_entry.title} - #{@blog_entry.date}"
  end

  it "should include models in property wrappers" do
    props = AnotherBlogEntry.get_list_properties
    props.find{|p| p.name == :title}.model.should == AnotherBlogEntry
    props.find{|p| p.name == :category}.model.should == Category
    props = AnotherBlogEntry.get_form_properties
    props.find{|p| p.name == :tags}.model.should == Tag
  end

  it "should include types in property wrappers" do
    props = AnotherBlogEntry.get_list_properties
    props.find{|p| p.name == :title}.type.should == 'string'
    props.find{|p| p.name == :category}.type.should == 'belongs_to'
    props = AnotherBlogEntry.get_form_properties
    props.find{|p| p.name == :tags}.type.should == 'many_to_many'
  end
  
  it "should get proper model class for property backed by custom instance method" do
    prop = AnotherBlogEntry.get_list_properties.find{|p| p.name == :user_defined_method}
    prop.model.should == AnotherBlogEntry
  end

end
