# frozen_string_literal: true

require 'rails_helper'

describe Campagne, type: :integration do
  context 'pour une campagne sans évaluation' do
    let(:campagne) { create :campagne }
    let(:situation) { create :situation_inventaire }

    before { campagne.situations_configurations.create situation: situation }

    it 'supprime les dépendances' do
      expect do
        campagne.destroy
      end.to change { described_class.count }.by(-1)
                                             .and change { SituationConfiguration.count }.by(-1)
    end
  end

  describe "création d'une campagne avec des situations" do
    # parcours type
    let!(:situation_maintenance) { create :situation_maintenance }
    let!(:parcours_type) do
      parcours = create :parcours_type
      parcours.situations_configurations.create situation: situation_maintenance
      parcours
    end

    let(:situations_optionnelles) { nil }
    let(:campagne) do
      create :campagne, situations_optionnelles: situations_optionnelles,
                        parcours_type: parcours_type
    end

    it 'crée la campagne avec les situations du parcours type' do
      expect do
        campagne
      end.to change { described_class.count }.by(1)

      campagne.reload
      situations_configurations = campagne.situations_configurations.includes(:situation)
      expect(situations_configurations[0].situation).to eq situation_maintenance
    end

    context 'quand il y a des situations optionnelles' do
      let!(:situation_plan_de_la_ville) { create :situation_plan_de_la_ville }
      let!(:situation_bienvenue) { create :situation_bienvenue }
      let(:situations_optionnelles) { %w[plan_de_la_ville bienvenue] }

      it "crée la campagne dans l'ordre des situations optionnelles" do
        expect do
          campagne
        end.to change { described_class.count }.by(1)

        campagne.reload
        situations_configurations = campagne.situations_configurations.includes(:situation)
        expect(situations_configurations[0].situation).to eq situation_plan_de_la_ville
        expect(situations_configurations[1].situation).to eq situation_bienvenue
        expect(situations_configurations[2].situation).to eq situation_maintenance
      end
    end
  end
end
