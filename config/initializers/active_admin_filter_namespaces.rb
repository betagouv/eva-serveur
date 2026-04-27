# Empêche les inputs top-level (ex. ::SelectInput dans app/inputs/) d'écraser
# ActiveAdmin::Inputs::Filters::SelectInput dans les sidebars de filtres.
# Sans ce reordering, Formtastic résout `as: :select` à ::SelectInput via
# Object.const_get et le module ActiveAdmin::Inputs::Filters::Base
# (qui produit <div class="filter_form_field ...">) n'est pas appliqué.
Rails.application.config.to_prepare do
  ActiveAdmin::Filters::FormBuilder.input_namespaces = [
    ::ActiveAdmin::Inputs::Filters,
    ::ActiveAdmin::Inputs,
    ::Object,
    ::Formtastic::Inputs
  ]
end
