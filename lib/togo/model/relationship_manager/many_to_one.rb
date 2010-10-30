module Togo
  module DataMapper
    
    class ManyToOne < RelationshipManager
      def unset_value
        nil
      end

      def related_model
        @relationship.parent_model
      end

      def find_for_assignment
        related_model.get(@ids.first)
      end
    end

  end # DataMapper
end # Model
