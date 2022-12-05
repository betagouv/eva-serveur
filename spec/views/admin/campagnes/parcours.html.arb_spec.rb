# frozen_string_literal: true

require 'rails_helper'

describe 'admin/campagnes/_programme.html.arb' do
  before { assign(:campagne, Campagne.new(parcours_type: parcours_type)) }

  let(:parcours_type) { nil }
  let(:maintenance) do
    create :situation,
           nom_technique: :maintenance,
           libelle: 'Maintenance'
  end
  let(:situation_configuration_maintenance) { SituationConfiguration.new(situation: maintenance) }
  before { assign(:situations_configurations, [situation_configuration_maintenance]) }

  before { render }

  it { expect(rendered).to match(/Maintenance/) }

  context 'sans parcours type' do
    it { expect(rendered).to match(/Parcours personnalisé/) }
  end

  context 'avec parcours_type' do
    let(:parcours_type) { ParcoursType.new libelle: 'Mon libellé' }

    it { expect(rendered).to match(/Mon libellé/) }
  end
end
