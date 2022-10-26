# frozen_string_literal: true

require 'rails_helper'

describe StatistiquesStructure do
  describe '#nombre_evaluations_des_3_derniers_mois' do
    let!(:eva) { create :structure_locale, nom: 'eva', structure_referente: paris }
    let!(:paris) do
      create :structure_administrative, nom: 'Paris', structure_referente: ile_de_france
    end
    let!(:ile_de_france) do
      create :structure_administrative, nom: 'Ile-de-France', structure_referente: france
    end
    let!(:france) { create :structure_administrative, nom: 'France' }

    let(:compte) { create :compte, structure: eva }
    let(:campagne) { create :campagne, compte: compte }
    let!(:evaluation) { create :evaluation, campagne: campagne }

    let(:resultat) { StatistiquesStructure.new(structure).nombre_evaluations_des_3_derniers_mois }

    context 'pour une structure locale' do
      let(:structure) { eva }

      it do
        mois_courant = I18n.l(Date.current, format: '%B')
        expect(resultat).to eq({ ['eva', mois_courant] => 1 })
      end
    end

    context 'pour une structure administrative (département)' do
      let(:structure) { paris }

      it do
        mois_courant = I18n.l(Date.current, format: '%B')
        expect(resultat).to eq({ ['eva', mois_courant] => 1 })
      end
    end

    context 'pour une structure administrative (régionale)' do
      let(:structure) { ile_de_france }

      it do
        mois_courant = I18n.l(Date.current, format: '%B')
        expect(resultat).to eq({ ['Paris', mois_courant] => 1 })
      end
    end

    context 'pour une structure administrative (nationale)' do
      let(:structure) { france }

      it do
        mois_courant = I18n.l(Date.current, format: '%B')
        expect(resultat).to eq({ ['Ile-de-France', mois_courant] => 1 })
      end

      context "avec plusieurs évaluations pour l'Île-de-france" do
        let!(:val_de_marne) do
          create :structure_administrative, nom: 'Val-de-marne', structure_referente: ile_de_france
        end

        let!(:compte2) { create :compte, structure: val_de_marne }
        let!(:campagne2) { create :campagne, compte: compte }
        let!(:evaluation2) { create :evaluation, campagne: campagne }

        it do
          mois_courant = I18n.l(Date.current, format: '%B')
          expect(resultat).to eq({ ['Ile-de-France', mois_courant] => 2 })
        end
      end
    end
  end
end
