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
  inflect.irregular 'situation_configuration', 'situations_configurations'
  inflect.irregular 'questionnaire_question', 'questionnaires_questions'
  inflect.irregular 'choix', 'choix'
  inflect.irregular 'nouvelle_structure', 'nouvelles_structures'
  inflect.irregular 'type_document', 'types_document'
  inflect.irregular 'question_frequente', 'questions_frequentes'
  inflect.irregular 'statut_validation', 'statuts_validation'
  inflect.irregular 'parcours_type', 'parcours_type'
  inflect.irregular 'structure_locale', 'structures_locales'
  inflect.irregular 'structure_administrative', 'structures_administratives'
  inflect.irregular 'partie', 'parties'
  inflect.irregular 'donnee_sociodemographique', 'donnees_sociodemographiques'
  inflect.irregular 'type_de_programme', 'types_de_programme'
  inflect.irregular 'mise_en_action', 'mises_en_action'
  inflect.irregular 'connexion_demo', 'connexions_demo'
  inflect.irregular 'question_saisie', 'questions_saisies'
end

# These inflection rules are supported but not enabled by default:
# ActiveSupport::Inflector.inflections(:en) do |inflect|
#   inflect.acronym 'RESTful'
# end
