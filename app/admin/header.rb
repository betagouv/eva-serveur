module ActiveAdmin
  module Views
    module HeaderEvaproOverride
      def build(namespace, menu)
        if helpers.respond_to?(:current_compte) &&
            helpers.current_compte&.structure&.eva_entreprises?
          render partial: "components/header"
        else
          super
        end
      end
    end
  end
end

ActiveAdmin::Views::Header.prepend(ActiveAdmin::Views::HeaderEvaproOverride)
