require 'rails'

module EmbeddedAssociations

  class Engine < ::Rails::Engine
    initializer "embedded_associations" do
      ActiveSupport.on_load(:action_controller) do
        include EmbeddedAssociations
      end
    end
  end

end