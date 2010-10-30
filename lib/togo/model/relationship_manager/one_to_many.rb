module Togo
  module DataMapper
    
    class OneToMany < RelationshipManager
      def unset_value
        []
      end

      def related_model
        @relationship.child_model
      end

      def find_for_assignment
        related_model.all(:id => @ids)
      end
    end

  end # DataMapper
end # Model
