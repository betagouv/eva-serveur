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

  def fin_situation?
    nom == 'finSituation'
  end

  def reponse_intitule
    donnees['reponseIntitule'].presence || donnees['reponse']
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

  def self.questions_repondues
    reponses.select("donnees->>'question' AS question").map(&:question)
  end

  def self.questions_non_repondues(questionnaire, noms_techniques)
    questionnaire&.questions&.reject do |q|
      questions_repondues.include?(q.nom_technique) ||
        q.sous_consigne? ||
        noms_techniques.any? { |noms| q.nom_technique.start_with?(*noms) }
    end
  end

  def self.questions_repondues_et_non_repondues(questionnaire, noms_techniques)
    non_repondues = questions_non_repondues(questionnaire,
                                            noms_techniques).map(&:as_json).each do |q|
      q['scoreMax'] = q.delete('score')
      q['question'] = q.delete('nom_technique')
    end
    reponses.map(&:donnees) + non_repondues
  end
end
