# frozen_string_literal: true

require 'rails_helper'

describe StatistiquesStructure do
  describe '#nombre_evaluations_des_12_derniers_mois' do
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
    let!(:evaluation) do
      Timecop.freeze(1.month.ago) do
        create :evaluation, campagne: campagne
      end
    end

    let(:resultat) { described_class.new(structure).nombre_evaluations_des_12_derniers_mois }

    let(:mois_courant) { I18n.l(1.month.ago, format: '%B %Y') }

    context 'pour une structure locale' do
      let(:structure) { eva }

      it { expect(resultat).to eq({ [ 'eva', mois_courant ] => 1 }) }
    end

    context 'pour une structure administrative (département)' do
      let(:structure) { paris }

      it { expect(resultat).to eq({ [ 'eva', mois_courant ] => 1 }) }
    end

    context 'pour une structure administrative (régionale)' do
      let(:structure) { ile_de_france }

      it { expect(resultat).to eq({ [ 'Paris', mois_courant ] => 1 }) }
    end

    context 'pour une structure administrative (nationale)' do
      let(:structure) { france }

      it { expect(resultat).to eq({ [ 'Ile-de-France', mois_courant ] => 1 }) }

      context "avec plusieurs évaluations pour l'Île-de-france" do
        let!(:val_de_marne) do
          create :structure_administrative, nom: 'Val-de-marne', structure_referente: ile_de_france
        end

        let!(:compte2) { create :compte, structure: val_de_marne }
        let!(:campagne2) { create :campagne, compte: compte }
        let!(:evaluation2) do
          Timecop.freeze(1.month.ago) do
            create :evaluation, campagne: campagne
          end
        end

        it { expect(resultat).to eq({ [ 'Ile-de-France', mois_courant ] => 2 }) }
      end
    end
  end

  describe '#repartition_evaluations' do
    let(:structure) { create :structure }
    let(:compte) { create :compte, structure: structure }
    let(:campagne) { create :campagne, compte: compte }

    let(:resultat) { described_class.new(structure).repartition_evaluations }

    context "quand l'évaluation appartient à la structure" do
      let(:synthese) { :ni_ni }

      before do
        Timecop.freeze(1.month.ago) do
          create :evaluation, campagne: campagne, synthese_competences_de_base: synthese
        end
      end

      context 'avec une synthexe ni_ni' do
        let(:synthese) { :ni_ni }

        it 'est prise en compte dans le calcul' do
          expect(resultat).to eq({ 'Niveau Intermédiaire' => 1 })
        end
      end

      context 'avec une synthexe ni_ni' do
        let(:synthese) { :socle_clea }

        it 'est prise en compte dans le calcul' do
          expect(resultat).to eq({ 'Pas de difficultés repérées' => 1 })
        end
      end

      context 'avec une synthexe illettrisme_potentiel' do
        let(:synthese) { :illettrisme_potentiel }

        it 'est prise en compte dans le calcul' do
          expect(resultat).to eq({ 'Illettrisme potentiel' => 1 })
        end
      end
    end

    context "quand l'évaluation n'appartient pas à la structure" do
      let(:autre_campagne) { create :campagne }

      before do
        create :evaluation, campagne: autre_campagne, synthese_competences_de_base: :ni_ni
      end

      it "n'est pas prise en compte dans le calcul" do
        expect(resultat).to eq({})
      end
    end

    context "quand l'évaluation n'a pas de synthèse compétence de base" do
      before do
        create :evaluation, campagne: campagne, synthese_competences_de_base: nil
      end

      it "n'est pas prise en compte dans le calcul" do
        expect(resultat).to eq({})
      end
    end

    context "quand l'évaluation a une synthèse compétence de base : aberrant" do
      before do
        create :evaluation, campagne: campagne, synthese_competences_de_base: :aberrant
      end

      it "n'est pas prise en compte dans le calcul" do
        expect(resultat).to eq({})
      end
    end
  end

  describe '#correlation_entre_niveau_illettrisme_et_genre' do
    let(:structure) { create :structure }
    let(:compte) { create :compte, structure: structure }
    let(:campagne) { create :campagne, compte: compte }

    let(:evaluation) do
      create :evaluation, campagne: campagne, synthese_competences_de_base: :illettrisme_potentiel
    end
    let(:evaluation2) do
      create :evaluation, campagne: campagne, synthese_competences_de_base: :illettrisme_potentiel
    end
    let(:evaluation_autre) do
      create :evaluation, synthese_competences_de_base: :illettrisme_potentiel
    end

    let(:resultat) do
      described_class.new(structure)
                     .correlation_entre_niveau_illettrisme_et_genre(:illettrisme_potentiel)
    end

    context "quand la structure n'a pas de données sociodémographiques" do
      it 'ne renvoie rien' do
        expect(resultat).to be_nil
      end
    end

    context 'quand la structure a des données sociodémographiques' do
      let!(:donnee_sociodemographique) do
        create :donnee_sociodemographique, genre: 'femme', evaluation: evaluation
      end
      let!(:donnee_sociodemographique2) do
        create :donnee_sociodemographique, genre: 'homme', evaluation: evaluation2
      end
      let!(:donnee_sociodemographique_autre) do
        create :donnee_sociodemographique, genre: 'homme', evaluation: evaluation_autre
      end

      it "renvoie le pourcentage d'un genre donné" do
        expect(resultat['femme']).to be(50.0)
        expect(resultat['homme']).to be(50.0)
      end

      it 'assigne zero aux genres sans évaluation' do
        expect(resultat['autre']).to be(0)
      end
    end
  end
end
