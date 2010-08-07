%w(dm-core rack dm-serializer).each{|l| require l}
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
      @q = params[:q] || ''
      @p = (params[:p] || 1).to_i
      @limit = 5
      @offset = @limit*(@p-1)
      @count = (@q.blank? ? @model.all : @model.search(:q => @q)).size
      @page_count = (@count.to_f/@limit.to_f).ceil
      @criteria = {:limit => @limit, :offset => @offset}
      @content = @q.blank? ? @model.all(@criteria) : @model.search(@criteria.merge(:q => @q))
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

    post '/delete/:model' do
      @items = @model.all(:id => params[:id].split(','))
      begin
        @items.each do |i|
          @model.delete_content(i)
        end
        redirect "/#{@model.name}"
      rescue => detail
        @errors = detail.to_s
        @content = params[:q] ? @model.search(:q => params[:q]) : @model.all
        erb :index
      end
    end

    get '/search/:model' do
      @limit = params[:limit] || 10
      @offset = params[:offset] || 0
      @q = params[:q] || ''
      @count = (@q.blank? ? @model.all : @model.search(:q => @q)).size
      @items = @model.search(:q => @q, :offset => @offset, :limit => @limit)
      {:count => @count, :results => @items}.to_json
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
