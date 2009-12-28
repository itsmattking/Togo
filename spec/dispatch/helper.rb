$TESTING=true
$:.push File.join(File.dirname(__FILE__), '..', '..', 'lib')
$:.push File.join(File.dirname(__FILE__), '..', '..', 'lib','togo')
%w(togo rack rack/test).each{|l| require l}

class DispatchTest < Togo::Dispatch

  get '/' do
    erb :index
  end

  get '/no-layout' do
    erb :index, :layout => false
  end

  get '/returns-last' do
    "return value"
  end

  get '/variable-test/:var' do
    params[:var]
  end

  get '/redirect-test' do
    redirect '/'
  end

  get '/exception-test' do
    raise StandardError, "Exception Test"
  end

end

def setup_browser
  Rack::Test::Session.new(Rack::MockSession.new(DispatchTest.new))
end
