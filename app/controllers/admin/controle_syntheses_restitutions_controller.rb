# frozen_string_literal: true

module Admin
  class ControleSynthesesRestitutionsController < ApplicationController # rubocop:disable Metrics/ClassLength
    SOUS_COMPETENCES_POSITIONNEMENT_LITTERATIE = [
      ['lecture', Restitution::SousCompetence::Litteratie.new(profil: ::Competence::PROFIL_1.to_s)],
      ['lecture', Restitution::SousCompetence::Litteratie.new(profil: ::Competence::PROFIL_2.to_s)],
      ['lecture', Restitution::SousCompetence::Litteratie.new(profil: ::Competence::PROFIL_3.to_s)],
      ['lecture', Restitution::SousCompetence::Litteratie.new(profil: ::Competence::PROFIL_4.to_s)],
      ['comprehension',
       Restitution::SousCompetence::Litteratie.new(profil: ::Competence::PROFIL_1.to_s)],
      ['comprehension',
       Restitution::SousCompetence::Litteratie.new(profil: ::Competence::PROFIL_2.to_s)],
      ['comprehension',
       Restitution::SousCompetence::Litteratie.new(profil: ::Competence::PROFIL_3.to_s)],
      ['comprehension',
       Restitution::SousCompetence::Litteratie.new(profil: ::Competence::PROFIL_4.to_s)],
      ['production',
       Restitution::SousCompetence::Litteratie.new(profil: ::Competence::PROFIL_1.to_s)],
      ['production',
       Restitution::SousCompetence::Litteratie.new(profil: ::Competence::PROFIL_2.to_s)],
      ['production',
       Restitution::SousCompetence::Litteratie.new(profil: ::Competence::PROFIL_3.to_s)],
      ['production',
       Restitution::SousCompetence::Litteratie.new(profil: ::Competence::PROFIL_4.to_s)]
    ].freeze
    SOUS_COMPETENCES_POSITIONNEMENT_NUMERATIE = [
      ['2_1', Restitution::SousCompetence::Numeratie.new(pourcentage_reussite: 100, succes: true,
                                                         nombre_total_questions: 18,
                                                         nombre_questions_repondues: 18,
                                                         nombre_questions_reussies: 18,
                                                         nombre_questions_echecs: 0,
                                                         nombre_questions_non_passees: 0)],
      ['2_2', Restitution::SousCompetence::Numeratie.new(pourcentage_reussite: 100, succes: true,
                                                         nombre_total_questions: 4,
                                                         nombre_questions_repondues: 4,
                                                         nombre_questions_reussies: 4,
                                                         nombre_questions_echecs: 0,
                                                         nombre_questions_non_passees: 0)],
      ['2_3', Restitution::SousCompetence::Numeratie.new(pourcentage_reussite: 100, succes: true,
                                                         nombre_total_questions: 28,
                                                         nombre_questions_repondues: 28,
                                                         nombre_questions_reussies: 28,
                                                         nombre_questions_echecs: 0,
                                                         nombre_questions_non_passees: 0)],
      ['2_4', Restitution::SousCompetence::Numeratie.new(pourcentage_reussite: 100, succes: true,
                                                         nombre_total_questions: 12,
                                                         nombre_questions_repondues: 12,
                                                         nombre_questions_reussies: 12,
                                                         nombre_questions_echecs: 0,
                                                         nombre_questions_non_passees: 0)],
      ['2_5', Restitution::SousCompetence::Numeratie.new(pourcentage_reussite: 100, succes: true,
                                                         nombre_total_questions: 12,
                                                         nombre_questions_repondues: 12,
                                                         nombre_questions_reussies: 12,
                                                         nombre_questions_echecs: 0,
                                                         nombre_questions_non_passees: 0)],
      ['2_1', Restitution::SousCompetence::Numeratie.new(pourcentage_reussite: 10, succes: false,
                                                         nombre_total_questions: 10,
                                                         nombre_questions_repondues: 1,
                                                         nombre_questions_reussies: 0,
                                                         nombre_questions_echecs: 1,
                                                         nombre_questions_non_passees: 0)],
      ['2_2', Restitution::SousCompetence::Numeratie.new(pourcentage_reussite: 10, succes: false,
                                                         nombre_total_questions: 10,
                                                         nombre_questions_repondues: 1,
                                                         nombre_questions_reussies: 0,
                                                         nombre_questions_echecs: 1,
                                                         nombre_questions_non_passees: 0)],
      ['2_3', Restitution::SousCompetence::Numeratie.new(pourcentage_reussite: 10, succes: false,
                                                         nombre_total_questions: 10,
                                                         nombre_questions_repondues: 1,
                                                         nombre_questions_reussies: 0,
                                                         nombre_questions_echecs: 1,
                                                         nombre_questions_non_passees: 0)],
      ['2_4', Restitution::SousCompetence::Numeratie.new(pourcentage_reussite: 10, succes: false,
                                                         nombre_total_questions: 10,
                                                         nombre_questions_repondues: 1,
                                                         nombre_questions_reussies: 0,
                                                         nombre_questions_echecs: 1,
                                                         nombre_questions_non_passees: 0)],
      ['2_5', Restitution::SousCompetence::Numeratie.new(pourcentage_reussite: 10, succes: false,
                                                         nombre_total_questions: 10,
                                                         nombre_questions_repondues: 1,
                                                         nombre_questions_reussies: 0,
                                                         nombre_questions_echecs: 1,
                                                         nombre_questions_non_passees: 0)]
    ].freeze
    SOUS_COMPETENCES_DIAGNOSTIC = [
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
      @syntheses_diagnostic = syntheses_diagnostic
      @syntheses_positionnement_litteratie = syntheses_positionnement_litteratie
      @syntheses_positionnement_numeratie = syntheses_positionnement_numeratie
      @sous_competences_diagnostic = SOUS_COMPETENCES_DIAGNOSTIC
      @sous_competences_positionnement_litteratie = SOUS_COMPETENCES_POSITIONNEMENT_LITTERATIE
      @sous_competences_positionnement_numeratie = SOUS_COMPETENCES_POSITIONNEMENT_NUMERATIE
    end

    def syntheses_diagnostic
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
