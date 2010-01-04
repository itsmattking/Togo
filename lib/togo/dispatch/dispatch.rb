require 'rack'
require 'erubis'

module Togo
  class Dispatch
    attr_reader :request, :response, :params

    def initialize(config = {})
      @view_path = config[:view_path] || 'views'
      @togo_environment = ENV['RACK_ENV'] || 'development'
    end

    def symbolize_keys(hash)
      hash.inject({}){|m,v| m.merge!(v[0].to_sym => v[1])}
    end

    def call(env)
      dup.call!(env)
    end

    def call!(env)
      @request = Rack::Request.new(env)
      @response = Rack::Response.new

      answer(@request.env['REQUEST_METHOD'], @request.path_info)
      @response.finish
    end      

    def answer(type,path)
      method = nil
      @params = symbolize_keys(@request.GET.dup.merge!(@request.POST.dup))
      self.class.routes[type].each do |p,k,m|
        if match = p.match(path)
          method = m
          @params.merge!(k.zip(match.captures.to_a).inject({}){|o,v| o.merge!(v[0].to_sym => v[1])}) unless k.empty?
          break
        end
      end
      if method.nil?
        @response.status = 404
        @response.write("404 Not Found")
      else
        begin
          __before if defined? __before
          @response.write(send(method))
        rescue => detail
          @response.status = 500
          @response.write("Error: #{detail}")
        end
      end
    end
    
    def erb(content, opts = {}, &block)
      if content.is_a?(Symbol)
        content = File.open(File.join(@view_path,"#{content}.erb")).read
      end
      result = Erubis::Eruby.new(content).result(binding)
      if not block_given? and opts[:layout] != false
        result = erb(:layout){ result }
      end
      result
    end

    def redirect(location)
      @response.status = 301
      @response.headers['Location'] = location
      @response.finish
    end

    def development?
      @togo_environment == 'development'
    end

    class << self
      attr_accessor :routes
      
      def inherited(subclass)
        subclass.routes = {}
        subclass.send(:include, Rack::Utils)
        %w{GET POST}.each{|v| subclass.routes[v] = []}
      end
      
      def get(route, &block)
        answer('GET', route, &block)
      end

      def post(route, &block)
        answer('POST', route, &block)
      end

      def answer(type, route, &block)
        method_name = "__#{type.downcase}#{clean_path(route)}"
        k = []
        p = route.gsub(/(:\w+)/){|m| k << m[1..-1]; "([^?/#&]+)"}
        routes[type].push([/^#{p}$/,k,method_name])
        define_method(method_name, &block)
      end

      def before(&block)
        define_method("__before",&block)
      end

      def clean_path(path)
        path.gsub(/\/|\./, '__')
      end

      def run!(config = {})
        builder = Rack::Builder.new
        builder.use Rack::ShowExceptions
        builder.use TogoReloader
        builder.use Rack::Static, :urls => ['/css','/js','/img'], :root => (config[:public_path] || 'public')
        builder.run new(config)
        builder.to_app
      end

    end
    
  end # Dispatch

  # Subclass Rack Reloader to call DataMapper.auto_upgrade! on file reload
  class TogoReloader < Rack::Reloader
    def safe_load(*args)
      super(*args)
      ::DataMapper.auto_upgrade!
    end
  end

end # Togo
