require 'rails_helper'

describe 'admin/evaluations/evapro/_aller_plus_loin.html.erb' do
  it "affiche les 8 etapes des incontournables dans l'ordre" do
    render partial: 'admin/evaluations/evapro/aller_plus_loin'

    fragment = Nokogiri::HTML.fragment(rendered)
    cartes = fragment.css('.incontournables-etapes .incontournables-card')
    rangees = fragment.css('.incontournables-etapes .incontournables-etapes__rangee')

    expect(rangees.size).to eq(2)
    expect(rangees.map { |rangee| rangee.css('.incontournables-card').size }).to eq([ 4, 4 ])
    expect(cartes.size).to eq(8)
    expect(cartes.map { |carte| carte.at_css('.incontournables-card__numero')&.text&.strip }).to eq(
      %w[01 02 03 04 05 06 07 08]
    )
    expect(cartes.map { |carte| carte.at_css('.incontournables-card__titre')&.text&.strip }).to eq(
      [
        I18n.t('admin.evaluations.aller_plus_loin.etapes.informe'),
        I18n.t('admin.evaluations.aller_plus_loin.etapes.implique'),
        I18n.t('admin.evaluations.aller_plus_loin.etapes.repere'),
        I18n.t('admin.evaluations.aller_plus_loin.etapes.plan_actions'),
        I18n.t('admin.evaluations.aller_plus_loin.etapes.passe_commande'),
        I18n.t('admin.evaluations.aller_plus_loin.etapes.co_construis'),
        I18n.t('admin.evaluations.aller_plus_loin.etapes.forme_salaries'),
        I18n.t('admin.evaluations.aller_plus_loin.etapes.evalue_projet')
      ]
    )

    premiere_carte = cartes.first
    texte = premiere_carte.at_css('.incontournables-card__en-savoir-plus-texte')
    expect(texte.text.strip).to eq(
      I18n.t('admin.evaluations.aller_plus_loin.etapes.en_savoir_plus')
    )
    expect(premiere_carte.at_css('.incontournables-card__en-savoir-plus a')).to be_nil
  end
end
