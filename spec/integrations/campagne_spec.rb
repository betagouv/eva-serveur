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
    let!(:questionnaire_sans_livraison) { create :questionnaire, :livraison_sans_redaction }
    let!(:questionnaire_avec_livraison) { create :questionnaire, :livraison_avec_redaction }
    let!(:situation_livraison) do
      create :situation_livraison, questionnaire: questionnaire_sans_livraison
    end
    let(:parcours_type) do
      parcours = create :parcours_type
      parcours.situations_configurations.create situation: situation_livraison
      parcours
    end

    let(:options_personnalisation) { nil }
    let(:campagne) do
      create :campagne, options_personnalisation: options_personnalisation,
                        parcours_type: parcours_type
    end

    it 'crée la campagne avec les situations du parcours type' do
      expect do
        campagne
      end.to change { described_class.count }.by(1)

      campagne.reload
      situations_configurations = campagne.situations_configurations.includes(:situation)
      expect(situations_configurations[0].situation).to eq situation_livraison
    end

    context 'quand le parcours type a plusieurs situations' do
      let(:situation_maintenance) { create :situation_maintenance }

      let(:parcours_type) do
        parcours = create :parcours_type
        parcours.situations_configurations.create situation: situation_maintenance, position: 1
        parcours.situations_configurations.create situation: situation_livraison, position: 2
        parcours
      end

      it "crée la campagne avec les situations du parcours type dans l'ordre donné" do
        campagne.reload

        situations_configurations = campagne.situations_configurations.includes(:situation)
        expect(situations_configurations[0].situation).to eq situation_maintenance
        expect(situations_configurations[1].situation).to eq situation_livraison
      end
    end

    context 'quand il y a des situations optionnelles' do
      let!(:situation_plan_de_la_ville) { create :situation_plan_de_la_ville }
      let!(:situation_bienvenue) { create :situation_bienvenue }
      let(:options_personnalisation) { %w[plan_de_la_ville bienvenue] }

      it "crée la campagne dans l'ordre des situations optionnelles" do
        expect do
          campagne
        end.to change { described_class.count }.by(1)

        campagne.reload
        situations_configurations = campagne.situations_configurations.includes(:situation)
        expect(situations_configurations[0].situation).to eq situation_plan_de_la_ville
        expect(situations_configurations[1].situation).to eq situation_bienvenue
        expect(situations_configurations[2].situation).to eq situation_livraison
      end
    end

    context "pour la selection du module d'expression écrite" do
      let(:options_personnalisation) { Campagne::PERSONNALISATION }

      it 'utilise le questionnaire livraison avec redaction' do
        expect do
          campagne
        end.to change { described_class.count }.by(1)

        campagne.reload
        situations_configurations = campagne.situations_configurations
        expect(situations_configurations[0].situation).to eq situation_livraison
        questionnaire = situations_configurations[0].questionnaire
        expect(questionnaire.nom_technique).to eq Questionnaire::LIVRAISON_AVEC_REDACTION
        expect(situations_configurations.count).to eq 1
      end
    end
  end
end
