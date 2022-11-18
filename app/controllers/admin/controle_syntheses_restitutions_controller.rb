# frozen_string_literal: true

module Admin
  class ControleSynthesesRestitutionsController < ApplicationController
    def index
      @syntheses_pre_positionnement = syntheses_pre_positionnement
      @syntheses_positionnement = syntheses_positionnement
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
