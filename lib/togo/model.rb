require 'erubis/tiny'

module Togo
  module DataMapper
    module Model
      BLACKLIST = [:id, :position]

      def self.included(base)
        base.extend ClassMethods
        base.send(:class_variable_set, :@@list_properties, [])
        base.send(:class_variable_set, :@@form_properties, [])
        base.send(:class_variable_set, :@@custom_form_templates, {})
        base.send(:class_variable_set, :@@property_options, {})
        if MODELS.include?(base) # support code reloading
          MODELS[MODELS.index(base)] = base # preserve order of which models were loaded
        else
          MODELS << base
        end
      end

      module ClassMethods
        # Let the user determine what properties to show in list view
        def list_properties(*args)
          pick_properties(:list,*args)
        end
        
        # Let the user determine what properties to show in form view
        def form_properties(*args)
          pick_properties(:form,*args)
        end

        def property_options
          class_variable_get(:@@property_options)          
        end

        def configure_property(property,opts = {})
          class_variable_get(:@@property_options).merge!(property => opts)
        end

        # Let the user create a custom template for a property
        def custom_template_for(property,opts = {})
          if File.exists?(opts[:template])
            class_variable_get(:@@custom_form_templates)[property] = opts[:template]
          end
        end

        # Display the form template for a property
        def form_for(property,content)
          template = class_variable_get(:@@custom_form_templates)[property.name] || File.join(File.dirname(__FILE__),'types',"#{type_from_property(property)}.erb")
          Erubis::TinyEruby.new(File.open(template).read).result(binding)
        end

        def update_content!(id,attrs)
          stage_content(get(id),attrs).save!
        end

        def create_content!(attrs)
          stage_content(new,attrs).save!
        end

        def stage_content(content,attrs)
          content.attributes = properties.inject({}){|m,p| attrs[p.name.to_sym] ? m.merge!(p.name.to_sym => attrs[p.name.to_sym]) : m}
          content
        end

        private

        def type_from_property(property)
          case property
            when ::DataMapper::Property
              property.type.to_s.gsub(/^(.*?::)+/,'').to_s.downcase
            when ::DataMapper::Associations::ManyToOne::Relationship
              'belongs_to'
            else
              'string'
          end
        end

        def pick_properties(selection,*args)
          if class_variable_get(:"@@#{selection}_properties").empty?
            args = shown_properties.map{|p| p.name} if args.empty?
            class_variable_set(:"@@#{selection}_properties", args.collect{|a| shown_properties.select{|s| s.name == a}.first}.compact)
          end
          class_variable_get(:"@@#{selection}_properties")
        end

        def shown_properties
          properties.select{|p| not BLACKLIST.include?(p.name) and not p.name =~ /_id$/} + relationships.values
        end
      end

    end # Model
  end # DataMapper
end # Togo
