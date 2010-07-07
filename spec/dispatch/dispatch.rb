require File.dirname(__FILE__) + '/helper'

describe "Togo Dispatch" do

  before(:each) do
    @browser = setup_browser
  end

  it "should respond ok on request" do
    @browser.get '/'
    @browser.last_response.status.should == 200
  end

  it "should render layout with erb" do
    @browser.get '/'
    @browser.last_response.body.should =~ /<title>Togo<\/title>/
  end

  it "should render no layout when requested" do
    @browser.get '/no-layout'
    @browser.last_response.body.should_not =~ /<title>Togo<\/title>/
  end

  it "should return last value on method" do
    @browser.get '/returns-last'
    @browser.last_response.status.should == 200
    @browser.last_response.body.should == 'return value'
  end

  it "should set var in params" do
    @browser.get "/variable-test/foo"
    @browser.last_response.body.should == 'foo'
  end

  it "should redirect" do
    @browser.get('/redirect-test')
    @browser.last_response.status.should == 301
    @browser.last_response.headers['Location'].should == '/'
  end
      
  it "should return not found" do
    @browser.get('/not-found')
    @browser.last_response.status.should == 404
    @browser.last_response.body.should == '404 Not Found'
  end

  it "should rescue and display exceptions" do
    @browser.get('/exception-test')
    @browser.last_response.status.should == 500
    @browser.last_response.body.should =~ /Error: Exception Test/
  end

  it "should have routes" do
    DispatchTest.routes.should be_a(Hash)
  end

  it "should run before method" do
    @browser.get('/before-test')
    @browser.last_response.status.should == 200
    @browser.last_response.body.should == "true"
  end

end
