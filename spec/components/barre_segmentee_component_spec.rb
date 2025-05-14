# frozen_string_literal: true

# spec/components/barre_segmentee_component_spec.rb
require 'rails_helper'

describe BarreSegmenteeComponent, type: :component do
  subject(:component) do
    described_class.new(
      nombre_questions_reussies: nombre_questions_reussies,
      nombre_questions_echecs: nombre_questions_echecs,
      nombre_questions_non_passees: nombre_questions_non_passees,
      pourcentage_reussite: pourcentage_reussite
    )
  end

  let(:nombre_questions_reussies) { 5 }
  let(:nombre_questions_echecs) { 3 }
  let(:nombre_questions_non_passees) { 2 }
  let(:pourcentage_reussite) { 50 }

  it 'rendu correctement le composant avec un pourcentage non nul' do
    render_inline(component)

    expect(page).to have_css('.barre-segmentee')
    expect(page).to have_content("Réussite : #{nombre_questions_reussies}")
    expect(page).to have_content("Échec : #{nombre_questions_echecs}")
    expect(page).to have_content("Non passés : #{nombre_questions_non_passees}")
    expect(page).to have_content("Total : #{component.nombre_questions_total}")
    expect(page).to have_content("Score #{pourcentage_reussite}%")
  end

  it 'calcule correctement les pourcentages de largeur avec des valeurs non nulles' do
    render_inline(component)

    pourcentage_reussite = component.pourcentage_questions(nombre_questions_reussies)
    expect(page).to have_css(
      ".barre-segmentee__graphique-element--succes[style*='width: #{pourcentage_reussite}%']"
    )

    pourcentage_echecs = component.pourcentage_questions(nombre_questions_echecs)
    expect(page).to have_css(
      ".barre-segmentee__graphique-element--echec[style*='width: #{pourcentage_echecs}%']"
    )

    pourcentage_non_passees = component.pourcentage_questions(nombre_questions_non_passees)
    expect(page).to have_css(
      ".barre-segmentee__graphique-element--non-passee[style*='width: #{pourcentage_non_passees}%']"
    )
  end

  context 'quand le pourcentage est zéro' do
    let(:pourcentage_reussite) { 0 }

    it 'rendu correctement le composant sans affichage de score' do
      render_inline(component)

      expect(page).to have_css('.barre-segmentee')
      expect(page).to have_content('Score 0%')
    end
  end

  context 'quand le pourcentage est nil' do
    let(:pourcentage_reussite) { nil }

    it 'rendu correctement le composant sans affichage de score' do
      render_inline(component)

      expect(page).to have_css('.barre-segmentee')
      expect(page).not_to have_content('Score 0%')
    end
  end
end
