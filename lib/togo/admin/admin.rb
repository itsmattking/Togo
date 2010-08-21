module Helpers
  
  def paging_links(page, count, qs = {})
    prev_link, next_link = 'Previous', 'Next'
    if not qs.blank?
      qs = qs.keys.collect{|k|
        [k,escape(qs[k])].join('=') if not qs[k].blank?
      }.compact.join('&')
      qs = nil if qs.blank?
    end
      
    if not page == 1
      prev_link = "<a href=\"?p=#{[page-1, qs].compact.join('&')}\" rel=\"previous\">#{prev_link}</a>"
    end
    if not page == count and count > 1
      next_link = "<a href=\"?p=#{[page+1, qs].compact.join('&')}\" rel=\"next\">#{next_link}</a>"
    end
    [prev_link, next_link]
  end

end

module Togo
  class Admin < Dispatch

    include Helpers

    before do
      @model = Togo.const_get(params[:model]) if params[:model]
    end

    get '/' do
      redirect "/#{Togo.models.first}"
    end

    get '/:model' do
      @q = params[:q] || ''
      @p = (params[:p] || 1).to_i
      @limit = 50
      @offset = @limit*(@p-1)
      @order = (params[:o] || "id.desc").split('.').map(&:to_sym)
      @count = (@q.blank? ? @model.all : @model.search(:q => @q)).size
      @page_count = @count == 0 ? 1 : (@count.to_f/@limit.to_f).ceil
      @criteria = {:limit => @limit, :offset => @offset, :order => @order[0].send(@order[1])}
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
        erb :new
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
      @criteria = {:offset => @offset, :limit => @limit}
      if params[:ids]
        @items = @model.all(@criteria.merge(:id => params[:ids].split(',').map(&:to_i)))
      else
        @items = @model.search(@criteria.merge(:q => @q))
      end
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
