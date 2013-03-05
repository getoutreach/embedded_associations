require "embedded_associations/rails"
require "embedded_associations/version"

module EmbeddedAssociations

  def self.included(base)
    base.instance_eval do

      class_attribute :embedded_associations

      def self.embedded_association(definition)
        unless embedded_associations
          self.embedded_associations = Definitions.new
          before_filter :handle_embedded_associations, only: [:update, :create, :destroy]
        end
        self.embedded_associations = embedded_associations.add_definition(definition)
      end
    end
  end

  def handle_embedded_associations
    Processor.new(embedded_associations, self).run
  end

  def root_resource
    resource
  end

  def root_resource_name
    resource_name
  end

  # Simple callbacks for now, eventually should use a filter system
  def before_embedded(record, action); end

  class Definitions
    include Enumerable

    attr_accessor :definitions

    def initialize
      @definitions = []
    end

    # Keep immutable to prevent all controllers
    # from sharing the same copy
    def add_definition(definition)
      result = self.dup
      result.definitions << definition
      result
    end

    def initialize_copy(source)
      self.definitions = source.definitions.dup
    end

    def each(&block)
      self.definitions.each &block
    end
  end

  class Processor

    attr_reader :definitions
    attr_reader :controller

    def initialize(definitions, controller)
      @definitions = definitions
      @controller = controller
    end

    def run
      definitions.each do |definition|
        handle_resource(definition, controller.root_resource, controller.params[controller.root_resource_name])
      end
    end

    private

    # Definition can be either a name, array, or hash.
    def handle_resource(definition, parent, parent_params)
      if definition.is_a? Array
        return definition.each{|d| handle_resource(d, parent, parent_params)}
      end
      # normalize to a hash
      unless definition.is_a? Hash
        definition = {definition => nil}
      end

      definition.each do |name, child_definition|
        reflection = parent.class.reflect_on_association(name)
        attrs = parent_params && parent_params.delete(name.to_s)
        
        if reflection.collection?
          attrs ||= []
          handle_plural_resource parent, name, attrs, child_definition
        else
          handle_singular_resource parent, name, attrs, child_definition
        end
      end
    end

    def filter_attributes(name, attrs, action)
      attrs
    end

    def handle_plural_resource(parent, name, attr_array, child_definition)
      current_assoc = parent.send(name)

      # Mark non-existant records as deleted
      current_assoc.select{|r| attr_array.none?{|attrs| attrs['id'] && attrs['id'].to_i == r.id}}.each do |r|
        handle_resource(child_definition, r, nil) if child_definition
        run_before_destroy_callbacks(r)
        r.mark_for_destruction
      end

      attr_array.each do |attrs|
        if id = attrs['id']
          # can't use current_assoc.find(id), see http://stackoverflow.com/questions/11605120/autosave-ignored-on-has-many-relation-what-am-i-missing
          r = current_assoc.find{|r| r.id == id.to_i}
          attrs = filter_attributes(r.class.name, attrs, :update)
          handle_resource(child_definition, r, attrs) if child_definition
          r.assign_attributes(attrs)
          run_before_update_callbacks(r)
        else
          r = current_assoc.build()
          attrs = filter_attributes(r.class.name, attrs, :create)
          handle_resource(child_definition, r, attrs) if child_definition
          r.assign_attributes(attrs)
          run_before_create_callbacks(r)
        end
      end
    end

    def handle_singular_resource(parent, name, attrs, child_definition)
      current_assoc = parent.send(name)
      
      if r = current_assoc
        if attrs
          attrs = filter_attributes(r.class.name, attrs, :update)
          handle_resource(child_definition, r, attrs) if child_definition
          r.assign_attributes(attrs)
          run_before_update_callbacks(r)
        else
          handle_resource(child_definition, r, attrs) if child_definition
          run_before_destroy_callbacks(r)
          r.mark_for_destruction
        end
      elsif attrs
        r = parent.send("build_#{name}")
        attrs = filter_attributes(r.class.name, attrs, :create)
        handle_resource(child_definition, r, attrs) if child_definition
        r.assign_attributes(attrs)
        run_before_create_callbacks(r)
      end
    end

    def run_before_create_callbacks(record)
      controller.send(:before_embedded, record, :create)
    end

    def run_before_update_callbacks(record)
      controller.send(:before_embedded, record, :update)
    end

    def run_before_destroy_callbacks(record)
      controller.send(:before_embedded, record, :destroy)
    end
  end

end
