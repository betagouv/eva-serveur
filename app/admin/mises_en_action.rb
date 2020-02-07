# frozen_string_literal: true

ActiveAdmin.register MiseEnAction do
  permit_params :elements_decouverts, :precision_elements_decouverts, :recommandations_candidat,
                :type_recommandation, :precision_recommandation,
                :elements_facilitation_recommandation

  form do |f|
    f.semantic_errors
    f.inputs do
      f.input :elements_decouverts, as: :radio
      f.input :precision_elements_decouverts, input_html: { rows: 5 }
      f.input :recommandations_candidat, as: :radio
      f.input :type_recommandation
      f.input :precision_recommandation, input_html: { rows: 5 }
      f.input :elements_facilitation_recommandation, input_html: { rows: 5 }
    end
    f.actions
  end
end
