%w(dm-core rack).each{|l| require l}
Dir.glob(File.join('models','*.rb')).each{|f| require f}
DataMapper::Logger.new(STDOUT, :debug)
DataMapper.setup(:default, "mysql://root@localhost/togo_development")
DataMapper.auto_upgrade!

module Togo
  class Admin < Dispatch

    get '/' do
      redirect "/#{Togo.models.first}"
    end

    get '/:model' do
      @model = Togo.const_get(params[:model])
      @content = params[:q] ? @model.search(:q => params[:q]) : @model.all
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
end
