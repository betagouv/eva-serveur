class MiseEnAction < ApplicationRecord
  REMEDIATIONS = %w[formation_competences_de_base formation_metier
                    dispositif_remobilisation levee_freins_peripheriques
                    indetermine].freeze
  DIFFICULTES = %w[aucune_offre_formation offre_formation_inaccessible
                   freins_peripheriques accompagnement_necessaire
                   indetermine].freeze
  MOTIFS = %w[action_prevue].freeze
  REPONSE_JE_NE_SAIS_PAS = "je_ne_sais_pas".freeze

  belongs_to :evaluation

  validates :evaluation_id, uniqueness: true

  enum :remediation, REMEDIATIONS.zip(REMEDIATIONS).to_h, suffix: true
  enum :difficulte, DIFFICULTES.zip(DIFFICULTES).to_h, suffix: true
  enum :motif, MOTIFS.zip(MOTIFS).to_h, suffix: true

  acts_as_paranoid

  def self.je_ne_sais_pas_actif?
    # L'option "je ne sais pas" est activée si la variable d'environnement est définie
    # On peut supprimer cette vérification une fois l'ensemble de la feature livrée.
    # Sert de protection pour la prochaine mise en prod
    ENV["ACTIVE_MISE_EN_ACTION_JE_NE_SAIS_PAS"].present?
  end

  def effectuee_avec_remediation?
    effectuee && remediation.present?
  end

  def non_effectuee_avec_difficulte?
    effectuee == false && difficulte.present?
  end

  def effectuee?
    effectuee
  end

  def questionnaire
    return :motif if effectuee.nil?

    effectuee ? :remediation : :difficulte
  end

  def qualification
    send(questionnaire)
  end
end
