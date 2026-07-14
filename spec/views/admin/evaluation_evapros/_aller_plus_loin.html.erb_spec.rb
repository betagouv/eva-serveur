# frozen_string_literal: true

require 'rails_helper'

describe 'admin/evaluation_evapros/_aller_plus_loin.html.erb' do
  let(:urls_incontournables_bao) do
    b = 'https://www.bao-incontournables.fr'
    [
      "#{b}/etape-1-informer/",
      "#{b}/etape-2-impliquer/",
      "#{b}/etape-3-reperer-identifier/",
      "#{b}/etape-4-elaborer/",
      "#{b}/etape-5-commander/",
      "#{b}/etape-6-co-construire/",
      "#{b}/etape-7-former/",
      "#{b}/etape-8-evaluer/"
    ]
  end

  def titres_etapes_incontournables
    scope = %i[admin evaluation_evapros aller_plus_loin etapes]
    %i[
      informe implique repere plan_actions passe_commande co_construis forme_salaries evalue_projet
    ].map { |cle| I18n.t(cle, scope: scope) }
  end

  it "affiche les 8 etapes des incontournables dans l'ordre" do
    render partial: 'admin/evaluation_evapros/aller_plus_loin'

    fragment = Nokogiri::HTML.fragment(rendered)
    cartes = fragment.css('.incontournables-etapes .incontournables-card')
    rangees = fragment.css('.incontournables-etapes .incontournables-etapes__rangee')

    expect(rangees.size).to eq(2)
    expect(rangees.map { |rangee| rangee.css('.incontournables-card').size }).to eq([ 4, 4 ])
    expect(cartes.size).to eq(8)
    expect(cartes.map { |c| c.at_css('.incontournables-card__numero')&.text&.strip }).to eq(
      %w[01 02 03 04 05 06 07 08]
    )
    expect(cartes.map { |c| c.at_css('.incontournables-card__titre')&.text&.strip }).to eq(
      titres_etapes_incontournables
    )

    premiere = cartes.first
    texte = premiere.at_css('.incontournables-card__en-savoir-plus-texte')
    en_savoir = I18n.t('admin.evaluation_evapros.aller_plus_loin.etapes.en_savoir_plus')
    expect(texte.text.strip).to eq(en_savoir)
    expect(premiere.at_css('.incontournables-card__en-savoir-plus a')).to be_nil
    expect(premiere['href']).to eq(urls_incontournables_bao.first)
    expect(premiere['target']).to eq('_blank')
    expect(premiere['rel']).to eq('noopener noreferrer')
    expect(cartes.map { |c| c['href'] }).to eq(urls_incontournables_bao)
  end

  it "en PDF, affiche les cartes compactes sans lien" do
    render partial: "admin/evaluation_evapros/aller_plus_loin", locals: { pdf: true }

    fragment_pdf = Nokogiri::HTML.fragment(rendered)
    cartes_pdf = fragment_pdf.css(".incontournables-etapes .incontournables-card")

    expect(cartes_pdf.size).to eq(8)
    expect(fragment_pdf.css("a.incontournables-card")).to be_empty
    expect(cartes_pdf.map { |c| c["href"] }.compact).to eq([])
    expect(cartes_pdf.first["class"]).to include("incontournables-card--pdf")
    numero = cartes_pdf.first.at_css(".incontournables-card--pdf__conteneur--textes-numero")
    expect(numero.text.strip).to eq("01")
    titre = cartes_pdf.first.at_css(".incontournables-card--pdf__conteneur--textes-titre")
    expect(titre.text.strip).to eq(
      I18n.t(:informe, scope: %i[admin evaluation_evapros aller_plus_loin etapes])
    )
  end
end
