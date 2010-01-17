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

end
