# frozen_string_literal: true

require 'rails_helper'

describe 'admin/evaluations/evapro/_aller_plus_loin.html.erb' do
  before { render partial: 'admin/evaluations/evapro/aller_plus_loin' }

  let(:fragment) { Nokogiri::HTML.fragment(rendered) }
  let(:cartes) { fragment.css('.incontournables-etapes .incontournables-card') }
  let(:rangees) { fragment.css('.incontournables-etapes .incontournables-etapes__rangee') }

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
    scope = %i[admin evaluations aller_plus_loin etapes]
    %i[
      informe implique repere plan_actions passe_commande co_construis forme_salaries evalue_projet
    ].map { |cle| I18n.t(cle, scope: scope) }
  end

  it "affiche les 8 etapes des incontournables dans l'ordre" do
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
    en_savoir = I18n.t('admin.evaluations.aller_plus_loin.etapes.en_savoir_plus')
    expect(texte.text.strip).to eq(en_savoir)
    expect(premiere.at_css('.incontournables-card__en-savoir-plus a')).to be_nil
    expect(premiere['href']).to eq(urls_incontournables_bao.first)
    expect(premiere['target']).to eq('_blank')
    expect(premiere['rel']).to eq('noopener noreferrer')
    expect(cartes.map { |c| c['href'] }).to eq(urls_incontournables_bao)
  end
end
