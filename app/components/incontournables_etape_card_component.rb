# frozen_string_literal: true

class IncontournablesEtapeCardComponent < ViewComponent::Base
  def initialize(
    numero:,
    titre:,
    image_path:,
    couleur_texte:,
    couleur_fond:,
    image_alt:,
    url:,
    pdf: false
  )
    @numero = numero
    @titre = titre
    @image_path = image_path
    @couleur_texte = couleur_texte
    @couleur_fond = couleur_fond
    @image_alt = image_alt
    @url = url
    @pdf = pdf
  end

  def card_style
    "--incontournables-card-bg: #{@couleur_fond}; --incontournables-card-color: #{@couleur_texte};"
  end

  def en_savoir_plus_label
    I18n.t("admin.evaluations_evapro.aller_plus_loin.etapes.en_savoir_plus")
  end
end
