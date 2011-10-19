require 'active_support'
require 'active_record'

module ActiveRecord
  # == Active Model Clone
  # 
  # Handles a simple task of cloning all attributes of a AR object
  # Default behaviour is to not clone the foreign_keys.
  #
  # Possible options is:
  # :only => [] # only clone these attributes
  # :exclude => [] # Exlude these attributes, default is :id
  # :skip_relations => true|false #default is true
  #
  # Can be configured either on a model layer using
  #
  # class MyModel < ActiveRecord::Base
  # can_clone
  # end
  #
  # Or can be configured upon the call to clone_ar.

  module Clone
    extend ActiveSupport::Concern
    
    module ClassMethods
      @options = {}
      
      def can_clone(options={})
        @options = default_options.keep_merge(options)
      end
            
      private
      # :nodoc
      def foreing_keys
        self.reflect_on_all_associations.map { |assoc| assoc.association_foreign_key }
      end
      
      # :nodoc
      def default_options
        {
          :skip_relations => true,
          :excluded => [:id]
        }
      end
      
    end
    
    
    module InstanceMethods
      
      def clone_ar(options={})
        options = (self.instance_variable_get(:@options) ? self.instance_variable_get(:@options) : self.class.send(:default_options)).keep_merge(options)
        puts options
        attrs = []
        if options[:only] and options[:only].is_a? Array
          attrs = self.attribute_names.reject {|item| options[:only].include? item}
        else
          excluded = options[:excluded] + (options[:skip_relations] ? self.class.send(:foreing_keys) : [])

          attrs = self.attribute_names.reject { |item| excluded.include? item}
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