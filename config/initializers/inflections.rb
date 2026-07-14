# Be sure to restart your server when you modify this file.

# Add new inflection rules using the following format. Inflections
# are locale specific, and you may define rules for as many different
# locales as you wish. All of these examples are active by default:
# ActiveSupport::Inflector.inflections(:en) do |inflect|
#   inflect.plural /^(ox)$/i, '\1en'
#   inflect.singular /^(ox)en/i, '\1'
#   inflect.irregular 'person', 'people'
#   inflect.uncountable %w( fish sheep )
# end

ActiveSupport::Inflector.inflections do |inflect|
  inflect.irregular 'choix', 'choix'
  inflect.irregular 'connexion_demo', 'connexions_demo'
  inflect.irregular 'donnee_sociodemographique', 'donnees_sociodemographiques'
  inflect.irregular 'evaluation_evapro', 'evaluations_evapro'
  inflect.irregular 'mise_en_action', 'mises_en_action'
  inflect.irregular 'nouvelle_structure', 'nouvelles_structures'
  inflect.irregular 'parcours_type', 'parcours_type'
  inflect.irregular 'opco_parcours_type', 'opcos_parcours_type'
  inflect.irregular 'partie', 'parties'
  inflect.irregular 'question_clic_dans_image', 'questions_clic_dans_image'
  inflect.irregular 'question_clic_dans_texte', 'questions_clic_dans_texte'
  inflect.irregular 'question_glisser_deposer', 'questions_glisser_deposer'
  inflect.irregular 'question_saisie', 'questions_saisies'
  inflect.irregular 'questionnaire_question', 'questionnaires_questions'
  inflect.irregular 'situation_configuration', 'situations_configurations'
  inflect.irregular 'statut_validation', 'statuts_validation'
  inflect.irregular 'structure_administrative', 'structures_administratives'
  inflect.irregular 'structure_locale', 'structures_locales'
  inflect.irregular 'structure_opco', 'structures_opcos'
  inflect.irregular 'type_de_programme', 'types_de_programme'
  inflect.irregular 'type_document', 'types_document'
end

# These inflection rules are supported but not enabled by default:
# ActiveSupport::Inflector.inflections(:en) do |inflect|
#   inflect.acronym 'RESTful'
# end
