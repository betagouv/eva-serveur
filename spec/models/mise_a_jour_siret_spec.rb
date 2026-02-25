require "rails_helper"

RSpec.describe MiseAJourSiret, type: :model do
  describe "#verifie_et_met_a_jour" do
    let(:structure) { build(:structure, siret: "12345678901234") }
    let(:client_sirene) { instance_double(Sirene::Client) }
    let(:mise_a_jour) { described_class.new(structure) }

    before do
      # Réinitialise les mocks globaux pour ces tests
      RSpec::Mocks.space.proxy_for(described_class).reset
      RSpec::Mocks.space.proxy_for(Sirene::Client).reset
      allow(Sirene::Client).to receive(:new).and_return(client_sirene)
    end

    context "quand le SIRET est valide" do
      let(:donnees_api) do
        {
          "results" => [
            {
              "siren" => "123456789",
              "nom_complet" => "ENTREPRISE TEST",
              "nom_raison_sociale" => "ENTREPRISE TEST",
              "activite_principale" => "53.10Z",
              "siege" => {
                "siret" => "12345678901234",
                "adresse" => "123 RUE DE LA REPUBLIQUE 75001 PARIS"
              },
              "matching_etablissements" => [],
              "complements" => {
                "liste_idcc" => [ "5516", "9999" ]
              }
            }
          ],
          "total_results" => 1
        }
      end

      before do
        allow(client_sirene).to receive(:recherche).with("12345678901234").and_return(donnees_api)
      end

      it "met à jour le statut SIRET à true" do
        mise_a_jour.verifie_et_met_a_jour
        expect(structure.statut_siret).to be true
      end

      it "met à jour la date de vérification" do
        freeze_time = Time.zone.parse("2024-01-15 10:00:00")
        Timecop.freeze(freeze_time) do
          mise_a_jour.verifie_et_met_a_jour
          expect(structure.date_verification_siret).to eq(freeze_time)
        end
      end

      it "met à jour le code NAF et les IDCC" do
        mise_a_jour.verifie_et_met_a_jour
        expect(structure.code_naf).to eq("53.10Z")
        expect(structure.idcc).to eq([ "5516", "9999" ])
      end

      it "met à jour la raison sociale et l'adresse" do
        mise_a_jour.verifie_et_met_a_jour
        expect(structure.raison_sociale).to eq("ENTREPRISE TEST")
        expect(structure.adresse).to eq("123 RUE DE LA REPUBLIQUE 75001 PARIS")
      end

      it "retourne true" do
        expect(mise_a_jour.verifie_et_met_a_jour).to be true
      end
    end

    context "quand le SIRET est invalide" do
      before do
        allow(client_sirene).to receive(:recherche).with("12345678901234").and_return(nil)
      end

      it "met le statut SIRET à false" do
        mise_a_jour.verifie_et_met_a_jour
        expect(structure.statut_siret).to be false
      end

      it "ne met pas à jour la date de vérification" do
        mise_a_jour.verifie_et_met_a_jour
        expect(structure.date_verification_siret).to be_nil
      end

      it "ne met pas à jour le code NAF et les IDCC" do
        mise_a_jour.verifie_et_met_a_jour
        expect(structure.code_naf).to be_nil
        expect(structure.idcc).to eq([])
      end

      it "ne met pas à jour la raison sociale et l'adresse" do
        mise_a_jour.verifie_et_met_a_jour
        expect(structure.raison_sociale).to be_nil
        expect(structure.adresse).to be_nil
      end

      it "retourne false" do
        expect(mise_a_jour.verifie_et_met_a_jour).to be false
      end
    end

    context "quand le SIRET n'est pas trouvé dans les résultats" do
      let(:donnees_api) do
        {
          "results" => [
            {
              "siren" => "123456789",
              "nom_complet" => "AUTRE ENTREPRISE",
              "siege" => {
                "siret" => "98765432109876"
              }
            }
          ],
          "total_results" => 1
        }
      end

      before do
        allow(client_sirene).to receive(:recherche).with("12345678901234").and_return(donnees_api)
      end

      it "ne met pas à jour le statut SIRET" do
        mise_a_jour.verifie_et_met_a_jour
        expect(structure.statut_siret).to be false
      end
    end

    context "quand le SIRET est trouvé mais déclaré fermé par l'API (etat_administratif F)" do
      let(:structure) { build(:structure_locale, siret: "45132137600035") }
      let(:donnees_api) do
        {
          "results" => [
            {
              "siren" => "451321376",
              "nom_complet" => "CARREFOUR STATIONS SERVICE",
              "siege" => {
                "siret" => "45132137600019",
                "etat_administratif" => "A"
              },
              "matching_etablissements" => [
                {
                  "siret" => "45132137600035",
                  "etat_administratif" => "F",
                  "adresse" => "CC GALERIE 96 AU 102 AV ST OUEN 75018 PARIS"
                }
              ]
            }
          ],
          "total_results" => 1
        }
      end

      before do
        allow(client_sirene).to receive(:recherche).with("45132137600035").and_return(donnees_api)
      end

      it "met le statut SIRET à false et marque la structure comme siret_ferme pour bloquer la création" do
        mise_a_jour.verifie_et_met_a_jour
        expect(structure.statut_siret).to be false
        expect(structure.siret_ferme).to be true
      end

      it "retourne false" do
        expect(mise_a_jour.verifie_et_met_a_jour).to be false
      end
    end

    context "quand le SIRET est valide mais sans IDCC" do
      let(:donnees_api) do
        {
          "results" => [
            {
              "siren" => "123456789",
              "nom_complet" => "ENTREPRISE TEST",
              "nom_raison_sociale" => "ENTREPRISE TEST",
              "activite_principale" => "53.10Z",
              "siege" => {
                "siret" => "12345678901234"
              },
              "matching_etablissements" => [],
              "complements" => {}
            }
          ],
          "total_results" => 1
        }
      end

      before do
        allow(client_sirene).to receive(:recherche).with("12345678901234").and_return(donnees_api)
      end

      it "met à jour le code NAF et un tableau vide pour IDCC" do
        mise_a_jour.verifie_et_met_a_jour
        expect(structure.code_naf).to eq("53.10Z")
        expect(structure.idcc).to eq([])
      end
    end

    context "quand le SIRET est valide avec adresse dans matching_etablissements" do
      let(:donnees_api) do
        {
          "results" => [
            {
              "siren" => "123456789",
              "nom_complet" => "ENTREPRISE TEST",
              "nom_raison_sociale" => "ENTREPRISE TEST",
              "activite_principale" => "53.10Z",
              "siege" => {
                "siret" => "98765432109876",
                "adresse" => "SIEGE ADRESSE"
              },
              "matching_etablissements" => [
                {
                  "siret" => "12345678901234",
                  "adresse" => "456 AVENUE DES CHAMPS 69000 LYON"
                }
              ],
              "complements" => {
                "liste_idcc" => [ "5516" ]
              }
            }
          ],
          "total_results" => 1
        }
      end

      before do
        allow(client_sirene).to receive(:recherche).with("12345678901234").and_return(donnees_api)
      end

      it "récupère l'adresse depuis matching_etablissements" do
        mise_a_jour.verifie_et_met_a_jour
        expect(structure.raison_sociale).to eq("ENTREPRISE TEST")
        expect(structure.adresse).to eq("456 AVENUE DES CHAMPS 69000 LYON")
      end
    end

    context "quand le SIRET est valide mais sans adresse" do
      let(:donnees_api) do
        {
          "results" => [
            {
              "siren" => "123456789",
              "nom_complet" => "ENTREPRISE TEST",
              "nom_raison_sociale" => "ENTREPRISE TEST",
              "activite_principale" => "53.10Z",
              "siege" => {
                "siret" => "12345678901234"
              },
              "matching_etablissements" => [],
              "complements" => {
                "liste_idcc" => [ "5516" ]
              }
            }
          ],
          "total_results" => 1
        }
      end

      before do
        allow(client_sirene).to receive(:recherche).with("12345678901234").and_return(donnees_api)
      end

      it "met à jour la raison sociale mais pas l'adresse" do
        mise_a_jour.verifie_et_met_a_jour
        expect(structure.raison_sociale).to eq("ENTREPRISE TEST")
        expect(structure.adresse).to be_nil
      end
    end

    context "quand nom_raison_sociale n'est pas présent, utilise nom_complet" do
      let(:donnees_api) do
        {
          "results" => [
            {
              "siren" => "123456789",
              "nom_complet" => "ENTREPRISE TEST FALLBACK",
              "activite_principale" => "53.10Z",
              "siege" => {
                "siret" => "12345678901234",
                "adresse" => "123 RUE DE LA REPUBLIQUE 75001 PARIS"
              },
              "matching_etablissements" => [],
              "complements" => {
                "liste_idcc" => [ "5516" ]
              }
            }
          ],
          "total_results" => 1
        }
      end

      before do
        allow(client_sirene).to receive(:recherche).with("12345678901234").and_return(donnees_api)
      end

      it "utilise nom_complet comme fallback pour la raison sociale" do
        mise_a_jour.verifie_et_met_a_jour
        expect(structure.raison_sociale).to eq("ENTREPRISE TEST FALLBACK")
      end
    end

    context "quand le SIRET est vide" do
      let(:structure) { build(:structure, siret: nil) }

      it "retourne false sans appeler l'API" do
        expect(client_sirene).not_to receive(:recherche)
        expect(mise_a_jour.verifie_et_met_a_jour).to be false
      end
    end
  end
end
