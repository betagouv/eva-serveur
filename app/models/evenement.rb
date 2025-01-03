# frozen_string_literal: true

class Evenement < ApplicationRecord
  validates :nom, :date, :session_id, presence: true
  # rubocop:disable Rails/UniqueValidationWithoutIndex
  validates :position, uniqueness: { scope: :session_id }
  # rubocop:enable Rails/UniqueValidationWithoutIndex
  belongs_to :partie, foreign_key: :session_id, primary_key: :session_id
  delegate :situation, :evaluation, to: :partie

  acts_as_paranoid

  scope :reponses, -> { where(nom: 'reponse') }
  scope :questions_repondues_et_non_repondues, lambda { |questionnaire, noms_techniques|
    noms_techniques_repondues = (noms_techniques + questions_repondues).flatten
    non_repondues = questionnaire.questions
                                 .includes(:illustration_attachment, :transcription_consigne,
                                           :transcription_intitule, :transcription_modalite_reponse)
                                 .non_repondues(noms_techniques_repondues)
    non_repondues = non_repondues.map(&:as_json).each do |q|
      q['scoreMax'] = q.delete('score')
      q['question'] = q.delete('nom_technique')
    end
    reponses.map(&:donnees) + non_repondues
  }

  def fin_situation?
    nom == 'finSituation'
  end

  def reponse_intitule
    donnees['reponseIntitule'].presence || donnees['reponse']
  end

  def self.questions_repondues
    reponses.select("donnees->>'question' AS question").map(&:question)
  end

  def self.regroupe_par_codes_clea(questionnaire, noms_techniques)
    groupes_clea = questions_repondues_et_non_repondues(questionnaire,
                                                        noms_techniques).group_by do |e|
      Metacompetence.new(e['metacompetence']).code_clea_sous_domaine
    end
    groupes_clea.transform_values do |groupes|
      groupes.group_by do |e|
        Metacompetence.new(e['metacompetence']).code_clea_sous_sous_domaine
      end
    end
  end
end
