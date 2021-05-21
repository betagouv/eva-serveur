# frozen_string_literal: true

json.questions questions
json.situations campagne.situations_configurations,
                partial: 'api/situations_configurations/situation_configuration',
                as: :situation_configuration
