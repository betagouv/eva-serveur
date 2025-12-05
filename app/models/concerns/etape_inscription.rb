module EtapeInscription
  extend ActiveSupport::Concern

  ETAPES_INSCRIPTION = %w[nouveau preinscription recherche_structure assignation_structure
complet].freeze

  included do
    validates :etape_inscription, inclusion: { in: ETAPES_INSCRIPTION }, if: -> {
 id_pro_connect.present? }
  end

  def doit_completer_inscription?
    etape_inscription != "complet"
  end

  def etape_inscription_nouveau?
    etape_inscription == "nouveau"
  end

  def etape_inscription_preinscription?
    etape_inscription == "preinscription"
  end

  def termine_preinscription!
    return if !etape_inscription_preinscription?

    if siret_pro_connect.blank?
      self.etape_inscription = "recherche_structure"
    else
      self.etape_inscription = "assignation_structure"
    end
  end

  def assigne_preinscription
    return if !etape_inscription_nouveau?

    self.etape_inscription = "preinscription"
  end
end
