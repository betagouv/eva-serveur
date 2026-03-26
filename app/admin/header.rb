module ActiveAdmin
  module Views
    module HeaderEvaproOverride
      def build(namespace, menu)
        return super unless helpers.respond_to?(:current_compte)

        current_compte = helpers.current_compte
        return super unless current_compte.present?

        partial =
          if current_compte.structure&.eva_entreprises?
            "components/header"
          else
            "components/header_eva"
          end
        render partial: partial
      end
    end
  end
end

ActiveAdmin::Views::Header.prepend(ActiveAdmin::Views::HeaderEvaproOverride)
