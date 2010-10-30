module Togo
  module DataMapper
    class RelationshipManager

      def self.create(content, relationship, opts = {})
        case relationship[1]
        when ::DataMapper::Associations::ManyToOne::Relationship
          ManyToOne.new(content, relationship, opts)
        when ::DataMapper::Associations::OneToMany::Relationship
          OneToMany.new(content, relationship, opts)
        end
      end

      def initialize(content, relationship, opts = {})
        @content = content
        @relationship = relationship[1]
        @relationship_name = relationship[0]
        @ids = (opts[:ids] || '').split(',').map(&:to_i)
      end

      def relate
        @content.send("#{@relationship_name}=", find_for_assignment)
        @content
      end
      
      def unset_values
        raise NotImplementedError
      end

      def related_model
        raise NotImplementedError
      end

      def find_for_assignment
        raise NotImplementedError
      end

    end
  end # DataMapper
end # Togo
