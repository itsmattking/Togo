require 'init'

DataMapper.auto_migrate!
c = Category.create(:name => 'Melting')
c2 = Category.create(:name => 'Exploding')
c3 = Category.create(:name => 'Gyrating')
BlogEntry.create(:title => 'My Mammy', :body => '', :date => Time.now, :category => c)
BlogEntry.create(:title => 'Whammy Bar', :body => '', :date => Time.now, :category => c2)
BlogEntry.create(:title => 'Kamakaze', :body => '', :date => Time.now, :category => c3)
BlogEntry.create(:title => 'Smile Bitches', :body => '', :date => Time.now, :category => c)
Range.new(0,20).each do |i|
  BlogEntry.create(:title => "Blog Entry #{i}", :body => "#{i} is the number", :date => Time.now, :category => c)
end

class DispatchApp < Togo::Dispatch

  get '/' do
    redirect "/#{Togo.models.first}"
  end

  get '/:model' do
    @model = Togo.const_get(params[:model])
    @content = @model.all
    erb :index
  end

  get '/new/:model' do
    @model = Togo.const_get(params[:model])
    @content = @model.new
    erb :new
  end

  post '/create/:model' do
    @model = Togo.const_get(params[:model])
    @content = @model.stage_content(@model.new,params)
    begin
      raise "Could not save content" if not @content.save
      redirect "/#{@model.name}"
    rescue => detail
      @errors = detail.to_s
      erb :edit
    end
  end

  get '/edit/:model/:id' do
    @model = Togo.const_get(params[:model])
    @content = @model.get(params[:id])
    erb :edit
  end

  post '/update/:model/:id' do
    @model = Togo.const_get(params[:model])
    @content = @model.stage_content(@model.get(params[:id]),params)
    begin
      raise "Could not save content" if not @content.save
      redirect "/#{@model.name}"
    rescue => detail
      @errors = detail.to_s
      erb :edit
    end
  end

end

#Rack::Handler::Thin.run(DispatchApp.run!)
