# frozen_string_literal: true

require 'rails_helper'

describe Restitution::DiagRisquesEntreprise do
  describe 'METRIQUES' do
    let(:diag_risques_entreprise) { Restitution::DiagRisquesEntreprise.new }
    let(:expected_instance) { Restitution::Entreprises::PourcentageRisque }

    it do
      expect(Restitution::DiagRisquesEntreprise::METRIQUES).to have_key('pourcentage_risque')
      expect(Restitution::DiagRisquesEntreprise::METRIQUES['pourcentage_risque']['instance'])
        .to be_an_instance_of(expected_instance)
    end
  end
end
