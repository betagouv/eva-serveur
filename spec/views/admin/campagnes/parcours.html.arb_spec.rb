# frozen_string_literal: true

require 'rails_helper'

describe 'admin/campagnes/_parcours.html.arb' do
  before { assign(:campagne, Campagne.new(parcours_type: parcours_type)) }
  before { assign(:auto_positionnement_inclus, true) }
  before { assign(:expression_ecrite_incluse, true) }
  before { render }

  context 'sans parcours type' do
    let(:parcours_type) { nil }
    it { expect(rendered).to match(/Parcours personnalisé/) }
  end

  context 'avec parcours_type' do
    let(:parcours_type) { ParcoursType.new libelle: 'Mon libellé' }
    it { expect(rendered).to match(/Mon libellé/) }
  end
end
