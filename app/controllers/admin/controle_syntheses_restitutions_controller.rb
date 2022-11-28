# frozen_string_literal: true

module Admin
  class ControleSynthesesRestitutionsController < ApplicationController
    SOUS_COMPETENCES = [['lecture', ::Competence::PROFIL_1],
                        ['lecture', ::Competence::PROFIL_2],
                        ['lecture', ::Competence::PROFIL_3],
                        ['lecture', ::Competence::PROFIL_4],
                        ['comprehension_ecrite', ::Competence::PROFIL_1],
                        ['comprehension_ecrite', ::Competence::PROFIL_2],
                        ['comprehension_ecrite', ::Competence::PROFIL_3],
                        ['comprehension_ecrite', ::Competence::PROFIL_4],
                        ['production_ecrite', ::Competence::PROFIL_1],
                        ['production_ecrite', ::Competence::PROFIL_2],
                        ['production_ecrite', ::Competence::PROFIL_3],
                        ['production_ecrite', ::Competence::PROFIL_4]].freeze

    def index
      @syntheses_pre_positionnement = syntheses_pre_positionnement
      @syntheses_positionnement = syntheses_positionnement
      @sous_competences_positionnement = SOUS_COMPETENCES
    end

    def syntheses_pre_positionnement
      [
        nil,
        'illettrisme_potentiel',
        'ni_ni',
        'socle_clea'
      ]
    end

    def syntheses_positionnement
      [[::Competence::NIVEAU_INDETERMINE, nil],
       [::Competence::PROFIL_ABERRANT, 'aberrant'],
       [::Competence::PROFIL_1, 'illettrisme_potentiel'],
       [::Competence::PROFIL_2, 'illettrisme_potentiel'],
       [::Competence::PROFIL_3, 'ni_ni'],
       [::Competence::PROFIL_4, 'socle_clea'],
       [::Competence::PROFIL_4H, 'socle_clea'],
       [::Competence::PROFIL_4H_PLUS, 'socle_clea'],
       [::Competence::PROFIL_4H_PLUS_PLUS, 'socle_clea']]
    end
  end
end
