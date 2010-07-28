require File.dirname(__FILE__) + '/helper'

describe "Togo Admin" do

  before(:each) do
    @browser = setup_browser
  end

  it "should redirect to first model at root" do
    @browser.get '/'
    @browser.last_response.status.should == 301
    @browser.last_response.headers['Location'].should == '/BlogEntry'
  end

  it "should create content" do
    @browser.post "/create/BlogEntry", :title => 'create content test', :body => 'body'
    @browser.last_response.status.should == 301
    @blog_entry = BlogEntry.first(:title => 'create content test')
    @blog_entry.should_not be_nil
    @browser.last_response.headers['Location'].should == "/BlogEntry"
  end

  it "should update content" do
    @blog_entry = BlogEntry.first(:title => 'create content test')
    @blog_entry.should_not be_nil
    @browser.post "/update/BlogEntry/#{@blog_entry.id}", :title => 'update content test'
    @browser.last_response.status.should == 301    
    @browser.last_response.headers['Location'].should == "/BlogEntry"
    @blog_entry = BlogEntry.first(:title => 'update content test')
    @blog_entry.should_not be_nil
  end

  it "should delete content" do
    @blog_entry = BlogEntry.create(:title => 'test 1234', :body => 'body')
    @browser.post "/delete/BlogEntry", :id => @blog_entry.id
    @browser.last_response.status.should == 301
    @browser.last_response.headers['Location'].should == '/BlogEntry'
    BlogEntry.first(:id => @blog_entry.id).should be_nil
  end

  it "should delete multiple content items" do
    @blog_entry_one = BlogEntry.create(:title => 'test 12345', :body => 'body')
    @blog_entry_two = BlogEntry.create(:title => 'test 12345', :body => 'body')
    BlogEntry.all(:id => [@blog_entry_one.id, @blog_entry_two.id]).size.should == 2
    @browser.post "/delete/BlogEntry", :id => [@blog_entry_one.id, @blog_entry_two.id].join(',')
    @browser.last_response.status.should == 301
    @browser.last_response.headers['Location'].should == '/BlogEntry'
    BlogEntry.all(:id => [@blog_entry_one.id, @blog_entry_two.id]).should be_empty
  end

  it "should silently fail to delete content" do
    @current_count = BlogEntry.all.size
    @browser.post "/delete/BlogEntry", :id => 123456
    @browser.last_response.status.should == 301
    @browser.last_response.headers['Location'].should == '/BlogEntry'
    @current_count.should == BlogEntry.all.size
  end

  it "should search model content" do
    b = BlogEntry.create(:title => "test 1234")
    @browser.get "/search/BlogEntry", :q => "test 1234"
    @browser.last_response.status.should == 200
    @browser.last_response.body.should == BlogEntry.search(:q => "test 1234").to_json
  end

  it "should search model content and allow paging" do
    b1 = BlogEntry.create(:title => "paging test blog entry 1")
    b2 = BlogEntry.create(:title => "paging test blog entry 2")
    @browser.get "/search/BlogEntry", :q => "paging test blog entry", :limit => 1, :offset => 1
    @browser.last_response.status.should == 200
    @browser.last_response.body.should == [b2].to_json
  end

end
