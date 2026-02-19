require 'rails_helper'

describe Campagne, type: :integration do
  context 'pour une campagne sans évaluation' do
    let(:campagne) { create :campagne }
    let(:situation) { create :situation_inventaire }

    before { campagne.situations_configurations.create situation: situation }

    it 'supprime les dépendances' do
      expect do
        campagne.destroy
      end.to change(described_class, :count).by(-1)
                                            .and change(SituationConfiguration, :count).by(-1)
    end
  end

  describe "Création d'une campagne avec des situations" do
    # parcours type
    let!(:questionnaire_sans_livraison) { create :questionnaire, :livraison_sans_redaction }
    let!(:questionnaire_avec_livraison) { create :questionnaire, :livraison_avec_redaction }
    let!(:questionnaire_socio_auto) do
      create :questionnaire, :sociodemographique_autopositionnement
    end
    let!(:questionnaire_socio_sante) do
      create :questionnaire, :sociodemographique_sante
    end
    let!(:questionnaire_socio_auto_sante) do
      create :questionnaire, :sociodemographique_autopositionnement_sante
    end
    let!(:bienvenue) { create :situation_bienvenue }
    let!(:situation_livraison) do
      create :situation_livraison, questionnaire: questionnaire_sans_livraison
    end
    let(:situation_maintenance) { create :situation_maintenance }
    let(:options_personnalisation) { nil }

    let(:parcours_type) do
      parcours = create :parcours_type
      parcours.situations_configurations.create situation: situation_livraison, position: 1
      parcours
    end
    let(:campagne) do
      create :campagne, options_personnalisation: options_personnalisation,
                        parcours_type: parcours_type
    end

    context 'quand le parcours type a plusieurs situations' do
      let(:parcours_type) do
        parcours = create :parcours_type
        parcours.situations_configurations.create situation: situation_livraison, position: 1
        parcours.situations_configurations.create situation: situation_maintenance, position: 2
        parcours
      end

      it "crée la campagne avec les situations du parcours type dans l'ordre donné" do
        campagne.reload

        situations_configurations = campagne.situations_configurations.includes(:situation)
        expect(situations_configurations[0].situation).to eq situation_livraison
        expect(situations_configurations[1].situation).to eq situation_maintenance
      end
    end

    context 'options de personnalisation' do
      context 'pour la selection de plan de la ville' do
        let!(:situation_plan_de_la_ville) { create :situation_plan_de_la_ville }
        let(:options_personnalisation) { %w[plan_de_la_ville] }

        it "crée la campagne dans l'ordre des situations optionnelles" do
          expect do
            campagne
          end.to change(described_class, :count).by(1)

          campagne.reload
          situations_configurations = campagne.situations_configurations.includes(:situation)
          expect(situations_configurations[0].situation).to eq situation_plan_de_la_ville
          expect(situations_configurations[1].situation).to eq situation_livraison
        end
      end

      context "pour la selection du module d'expression écrite" do
        let(:options_personnalisation) { %w[redaction] }

        it 'utilise le questionnaire livraison avec redaction' do
          expect do
            campagne
          end.to change(described_class, :count).by(1)

          campagne.reload
          situations_configurations = campagne.situations_configurations
          expect(situations_configurations[0].situation).to eq situation_livraison
          questionnaire = situations_configurations[0].questionnaire
          expect(questionnaire.nom_technique).to eq Questionnaire::LIVRAISON_AVEC_REDACTION
          expect(situations_configurations.count).to eq 1
        end
      end

      context "pour la selection de l'autopositionnement" do
        let(:options_personnalisation) { %w[autopositionnement] }
        let(:parcours_type) do
          parcours = create :parcours_type
          parcours.situations_configurations.create situation: bienvenue, position: 1
          parcours
        end

        it 'utilise le questionnaire sociodemographique_autopositionnement' do
          expect do
            campagne
          end.to change(described_class, :count).by(1)

          campagne.reload

          situations_configurations = campagne.situations_configurations.includes(:situation)
          expect(situations_configurations.count).to eq 1
          expect(situations_configurations[0].situation.nom_technique).to eq 'bienvenue'
          questionnaire = situations_configurations[0].questionnaire
          expect(questionnaire).to eq questionnaire_socio_auto
        end
      end

      context "pour la selection du questionnaire de santé" do
        let(:options_personnalisation) { %w[questionnaire_sante] }
        let(:parcours_type) do
          parcours = create :parcours_type
          parcours.situations_configurations.create situation: bienvenue, position: 1
          parcours
        end

        it 'utilise le questionnaire sociodemographique_sante' do
          expect { campagne }.to change(described_class, :count).by(1)

          campagne.reload

          situations_configurations = campagne.situations_configurations.includes(:situation)
          expect(situations_configurations.count).to eq 1
          expect(situations_configurations[0].situation.nom_technique).to eq 'bienvenue'
          questionnaire = situations_configurations[0].questionnaire
          expect(questionnaire).to eq questionnaire_socio_sante
        end
      end

      context "pour la selection du questionnaire d'autopositionnement et de santé" do
        let(:options_personnalisation) { %w[autopositionnement questionnaire_sante] }
        let(:parcours_type) do
          parcours = create :parcours_type
          parcours.situations_configurations.create situation: bienvenue, position: 1
          parcours
        end

        it 'utilise le questionnaire sociodemographique_autopositionnement_sante' do
          expect { campagne }.to change(described_class, :count).by(1)

          campagne.reload

          situations_configurations = campagne.situations_configurations.includes(:situation)
          expect(situations_configurations.count).to eq 1
          expect(situations_configurations[0].situation.nom_technique).to eq 'bienvenue'
          questionnaire = situations_configurations[0].questionnaire
          expect(questionnaire).to eq questionnaire_socio_auto_sante
        end
      end
    end
  end
end
