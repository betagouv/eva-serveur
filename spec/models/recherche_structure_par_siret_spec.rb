# frozen_string_literal: true

require "rails_helper"

RSpec.describe RechercheStructureParSiret, type: :model do
  describe "#call" do
    context "quand une structure existe en base pour le SIRET" do
      let(:siret) { "12345678901234" }
      let!(:structure_existante) { create(:structure_locale, siret: siret) }

      before do
        allow(MiseAJourSiret).to receive(:new) do |structure|
          mise_a_jour = instance_double(MiseAJourSiret)
          allow(mise_a_jour).to receive(:verifie_et_met_a_jour) do
            structure.statut_siret = true
            true
          end
          mise_a_jour
        end
      end


      it "retourne cette structure sans appeler l'API officielle" do
        resultat = described_class.new(siret).call

        expect(resultat).to eq(structure_existante)
        # Un seul appel (lors de la création de la structure), pas d'appel lors de la recherche
        expect(MiseAJourSiret).to have_received(:new).once
      end
    end

    context "quand le SIRET est saisi avec des espaces" do
      let(:siret_normalise) { "12345678901234" }
      let(:siret_avec_espaces) { "123 456 789 01234" }
      let!(:structure_existante) { create(:structure_locale, siret: siret_normalise) }

      it "retourne la structure existante (recherche insensible aux espaces)" do
        resultat = described_class.new(siret_avec_espaces).call

        expect(resultat).to eq(structure_existante)
      end
    end

    context "quand aucune structure n'existe en base pour le SIRET" do
      let(:siret) { "98765432109876" }

      before do
        allow(MiseAJourSiret).to receive(:new) do |structure|
          mise_a_jour = instance_double(MiseAJourSiret)
          allow(mise_a_jour).to receive(:verifie_et_met_a_jour) do
            structure.statut_siret = false
            false
          end
          mise_a_jour
        end
      end

      it "appelle l'API et retourne une structure temporaire" do
        resultat = described_class.new(siret).call

        expect(resultat).to be_present
        expect(resultat).to be_new_record
        expect(resultat.siret).to eq(siret)
        expect(MiseAJourSiret).to have_received(:new)
      end
    end

    context "quand le SIRET est vide" do
      it "retourne nil" do
        expect(described_class.new("").call).to be_nil
        expect(described_class.new(nil).call).to be_nil
      end
    end
  end
end
