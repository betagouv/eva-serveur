# frozen_string_literal: true

json.questions @questions
json.situations @campagne.situations_configurations, partial: 'situation_configuration',
                                                     as: :situation_configuration
json.competences_fortes @competences
