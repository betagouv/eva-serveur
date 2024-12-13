# frozen_string_literal: true

module Admin
  class ControleSynthesesRestitutionsController < ApplicationController
    SOUS_COMPETENCES_POSITIONNEMENT_LITTERATIE = [
      ['lecture', { profil: ::Competence::PROFIL_1.to_s }],
      ['lecture', { profil: ::Competence::PROFIL_2.to_s }],
      ['lecture', { profil: ::Competence::PROFIL_3.to_s }],
      ['lecture', { profil: ::Competence::PROFIL_4.to_s }],
      ['comprehension', { profil: ::Competence::PROFIL_1.to_s }],
      ['comprehension', { profil: ::Competence::PROFIL_2.to_s }],
      ['comprehension', { profil: ::Competence::PROFIL_3.to_s }],
      ['comprehension', { profil: ::Competence::PROFIL_4.to_s }],
      ['production', { profil: ::Competence::PROFIL_1.to_s }],
      ['production', { profil: ::Competence::PROFIL_2.to_s }],
      ['production', { profil: ::Competence::PROFIL_3.to_s }],
      ['production', { profil: ::Competence::PROFIL_4.to_s }]
    ].freeze
    SOUS_COMPETENCES_POSITIONNEMENT_NUMERATIE = [
      ['2_1', { pourcentage: 100, profil: true }],
      ['2_2', { pourcentage: 100, profil: true }],
      ['2_3', { pourcentage: 100, profil: true }],
      ['2_4', { pourcentage: 100, profil: true }],
      ['2_5', { pourcentage: 100, profil: true }],
      ['2_1', { pourcentage: 10, profil: false }],
      ['2_2', { pourcentage: 10, profil: false }],
      ['2_3', { pourcentage: 10, profil: false }],
      ['2_4', { pourcentage: 10, profil: false }],
      ['2_5', { pourcentage: 10, profil: false }]
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
      @sous_competences_positionnement_litteratie = SOUS_COMPETENCES_POSITIONNEMENT_LITTERATIE
      @sous_competences_positionnement_numeratie = SOUS_COMPETENCES_POSITIONNEMENT_NUMERATIE
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
