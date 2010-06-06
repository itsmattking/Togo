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

  it "should delete content" do
    @blog_entry = BlogEntry.create(:title => 'test 1234', :body => 'body')
    @browser.post "/delete/BlogEntry/#{@blog_entry.id}"
    @browser.last_response.status.should == 301
    @browser.last_response.headers['Location'].should == '/BlogEntry'
    BlogEntry.first(:id => @blog_entry.id).should be_nil
  end

end
