%w(dm-core rack).each{|l| require l}
Dir.glob(File.join('models','*.rb')).each{|f| require f}

module Togo
  class Admin < Dispatch

    before do
      @model = Togo.const_get(params[:model]) if params[:model]
    end

    get '/' do
      redirect "/#{Togo.models.first}"
    end

    get '/:model' do
      @content = params[:q] ? @model.search(:q => params[:q]) : @model.all
      erb :index
    end

    get '/new/:model' do
      @content = @model.new
      erb :new
    end

    post '/create/:model' do
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
      @content = @model.get(params[:id])
      erb :edit
    end

    post '/update/:model/:id' do
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

  # Subclass Rack Reloader to call DataMapper.auto_upgrade! on file reload
  class TogoReloader < Rack::Reloader
    def safe_load(*args)
      super(*args)
      ::DataMapper.auto_upgrade!
    end
  end

end
