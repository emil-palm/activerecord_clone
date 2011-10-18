module ActiveRecord
  module Clone
    extend ActiveSupport::Concern
    
    module ClassMethods
      @options = {}
      
      def can_clone(options={})
        @options = default_options.merge(options)
      end
            
      private
      
      def foreing_keys
        self.reflect_on_all_associations.map { |assoc| assoc.association_foreign_key }
      end
      
      def default_options
        {
          :skip_relations => true,
          :excluded => []
        }
      end
      
    end
    
    
    module InstanceMethods
      
      def clone_ar(options={})
        options = Account.instance_variable_get(:@options).merge(options)
        attrs = []
        if options[:only] and options[:only].is_a? Array
          attrs = self.attributes.reject {|item| options[:only].include? item}
        else
          excluded = options[:excluded] + (options[:skip_relations] ? self.class.send(:foreing_keys) : [])
          attrs = self.attribute_names
        end
        
        newObj = self.class.new
        attrs.each do |attribute|
          newObj.send(:write_attribute, attribute.to_sym, self.read_attribute(attribute.to_sym))
        end        
        yield newObj, self if block_given?
        return newObj
      end
      
    end
    
  end
end

::ActiveRecord::Base.send :include, ActiveRecord::Clone