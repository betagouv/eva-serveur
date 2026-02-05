# frozen_string_literal: true

module ActiveAdminEvaproAdminClass
  def body_classes
    classes = super
    classes << "evapro_admin" if evapro_admin_layout?
    classes
  end

  private

  def evapro_admin_layout?
    return @__evapro_admin_layout if defined?(@__evapro_admin_layout)

    current_compte = if respond_to?(:controller) && controller.respond_to?(:current_compte)
      controller.current_compte
    end
    @__evapro_admin_layout = current_compte&.structure&.eva_entreprises?
  end
end

unless ActiveAdmin::Views::Pages::Base.ancestors.include?(ActiveAdminEvaproAdminClass)
  ActiveAdmin::Views::Pages::Base.prepend(ActiveAdminEvaproAdminClass)
end
