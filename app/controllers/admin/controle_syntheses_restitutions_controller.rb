# frozen_string_literal: true

module Admin
  class ControleSynthesesRestitutionsController < ApplicationController
    SOUS_COMPETENCES_POSITIONNEMENT = [
      ['lecture', ::Competence::PROFIL_1],
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
      ['production_ecrite', ::Competence::PROFIL_4]
    ].freeze
    SOUS_COMPETENCES_PREPOSITIONNEMENT = [
      ['litteratie', :pre_A1],
      ['litteratie', :A1],
      ['litteratie', :A2],
      ['litteratie', :B1],
      ['numeratie', :pre_X1],
      ['numeratie', :X1],
      ['numeratie', :X2],
      ['numeratie', :Y1]
    ].freeze

    def index
      @syntheses_pre_positionnement = syntheses_pre_positionnement
      @syntheses_positionnement_litteratie = syntheses_positionnement_litteratie
      @syntheses_positionnement_numeratie = syntheses_positionnement_numeratie
      @sous_competences_prepositionnement = SOUS_COMPETENCES_PREPOSITIONNEMENT
      @sous_competences_positionnement = SOUS_COMPETENCES_POSITIONNEMENT
    end

    def syntheses_pre_positionnement
      [
        nil,
        'illettrisme_potentiel',
        'ni_ni',
        'socle_clea'
      ]
    end

    def syntheses_positionnement_litteratie
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

    def syntheses_positionnement_numeratie
      [[::Competence::NIVEAU_INDETERMINE, nil],
       [::Competence::PROFIL_1, 'illettrisme_potentiel'],
       [::Competence::PROFIL_2, 'illettrisme_potentiel'],
       [::Competence::PROFIL_3, 'ni_ni'],
       [::Competence::PROFIL_4, 'socle_clea']]
    end
  end
end
