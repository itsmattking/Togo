require 'rack'
require 'erubis'

module Togo

  class FlashHash
    def initialize
      @h = {}
      @c = {}
    end
    def [](key)
      return @c[key] if @c.keys.include?(key)
      @c[key] = @h.delete(key) if @h.keys.include?(key)
    end
    def []=(key,val)
      @h[key] = val
    end
    def sweep!
      @c = {}
    end
  end

  class Dispatch

    HANDLERS = %w(thin mongrel webrick)

    attr_reader :request, :response, :params

    def initialize(opts = {})
      @view_path = opts[:view_path] || 'views'
      ENV['RACK_ENV'] = (opts[:environment] || :development) if not ENV['RACK_ENV']
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
          @response.write(send(method)) unless [301, 302].include?(@response.status)
        rescue => detail
          @response.status = 500
          @response.write(["Error: #{detail}",$!.backtrace.join("<br />\n")].join("<br />\n"))
        end
      end
      flash.sweep!
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

    def redirect(location, opts = {})
      @response.status = (opts[:status] || 301)
      @response.headers['Location'] = location
      @response.finish
    end

    def environment?(name)
      ENV['RACK_ENV'] == name.to_sym
    end

    def session
      @request.session
    end

    def flash
      session[:flash] ||= FlashHash.new
    end

    def self.handler
      HANDLERS.each do |h|
        begin
          return Rack::Handler.get(h)
        rescue
        end
      end
      puts "Could not find any handlers to run. Please be sure your requested handler is installed."
    end

    def config
      self.class.send(:config)
    end

    class << self
      attr_accessor :routes, :config
      
      def inherited(subclass)
        subclass.routes = {}
        subclass.send(:include, Rack::Utils)
        %w{GET POST}.each{|v| subclass.routes[v] = []}
        subclass.config = {
          :public_path => 'public',
          :static_urls => ['/css','/js','/img'],
          :port => 8080,
          :host => '127.0.0.1',
          :environment => :development
        }
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
        r = [/^#{p}$/,k,method_name]
        if not routes[type].rindex{|t| t[0] == r[0]}
          routes[type].push(r)
          define_method(method_name, &block)
        end
      end

      def before(&block)
        define_method("__before",&block)
      end

      def clean_path(path)
        path.gsub(/\/|\./, '__')
      end

      def configure(opts = {})
        config.merge!(opts)
      end

      def run!(opts = {})
        opts = config.dup.merge!(opts)
        builder = Rack::Builder.new
        if opts[:environment].to_sym == :development
          puts "Showing exceptions and using reloader for Development..."
          builder.use Rack::ShowExceptions
          builder.use opts[:reloader] if opts[:reloader]
        end
        if opts[:routes] and opts[:routes].is_a?(Array)
          opts[:routes].each do |r|
            send(r[:type].to_sym, r[:path]) do
              erb r[:template].to_sym
            end
          end
        end
        builder.use Rack::Static, :urls => opts[:static_urls], :root => opts[:public_path]
        if opts[:sessions] or opts[:auth_model]
          builder.use Rack::Session::Cookie
          opts[:sessions] = true
        end
        builder.run new(opts)
        if opts[:standalone]
          opts[:handler].run(builder.to_app, :Port => opts[:port], :Host => opts[:host])
        else
          builder.to_app
        end
      end

    end
    
  end # Dispatch

end # Togo
