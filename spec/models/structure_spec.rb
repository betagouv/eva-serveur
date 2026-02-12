require 'rails_helper'

describe Structure, type: :model do
  it { is_expected.to validate_presence_of(:nom) }
  it { is_expected.to validate_uniqueness_of(:nom).scoped_to(:code_postal).case_insensitive }
  it { is_expected.to validate_numericality_of(:siret) }

  describe 'Ancestry primary key format' do
    it { expect('uuid invalide').not_to match(Ancestry.default_primary_key_format) }
    it { expect(SecureRandom.uuid).to match(Ancestry.default_primary_key_format) }
  end

  context 'quand une structure avec le même nom, même CP, a été soft-deleted' do
    let(:structure) { build :structure, nom: 'nom', code_postal: '75012' }

    before do
      structure_existante_effacee = create :structure, nom: 'nom', code_postal: '75012'
      structure_existante_effacee.destroy
    end

    it "Peut ré-utiliser le nom d'une structure effacé" do
      expect(structure.save).to be true
    end
  end

  def mock_geo_api(departement, code_region, region)
    mock_reponse_typhoeus("https://geo.api.gouv.fr/departements/#{departement}",
                          { codeRegion: code_region })

    mock_reponse_typhoeus("https://geo.api.gouv.fr/regions/#{code_region}",
                          { nom: region })
  end

  describe 'géolocalisation à la validation' do
    describe "pour n'importe quel code postal" do
      let(:structure) { described_class.new code_postal: '75012' }

      before do
        Geocoder::Lookup::Test.add_stub(
          '75012', [ { 'coordinates' => [ 40.7143528, -74.0059731 ] } ]
        )
        mock_geo_api(75, 11, 'Île-de-France')
        structure.valid?
      end

      it do
        expect(structure.latitude).to be(40.7143528)
        expect(structure.longitude).to be(-74.0059731)
        expect(structure.region).to eql('Île-de-France')
      end

      it { expect(described_class.geocoder_options[:params]).to include(countrycodes: 'fr') }
    end

    describe 'si ma structure a un code postal commençant par 988' do
      let(:structure) { described_class.new code_postal: '98850' }

      before do
        Geocoder::Lookup::Test.add_stub(
          '98850', [
            {
              'coordinates' => [ 47.3129, 120.0596 ]
            }
          ]
        )
        mock_geo_api(988, 988, 'Nouvelle-Calédonie')
        structure.valid?
      end

      it 'lui attribue la région Nouvelle-Calédonie' do
        expect(structure.region).to eql('Nouvelle-Calédonie')
      end
    end

    describe 'si ma structure a un code postal commençant par 20' do
      let(:structure) { described_class.new code_postal: '20090' }

      before do
        Geocoder::Lookup::Test.add_stub(
          '20090', [ { 'coordinates' => [ 41.9333, 8.7507 ] } ]
        )
        mock_geo_api('2A', 94, 'Corse')
        structure.valid?
      end

      it 'lui attribue la région Corse' do
        expect(structure.region).to eql('Corse')
      end
    end

    context 'quand ma structure a déjà une région' do
      let(:structure) { described_class.new code_postal: '20114', region: 'Corse' }

      before do
        structure.code_postal = '61000'
        Geocoder::Lookup::Test.add_stub(
          '61000', [
            {
              'coordinates' => [ 48.4310232, 0.0922579 ]
            }
          ]
        )
        mock_geo_api(61, 28, 'Normandie')
        structure.valid?
      end

      it 'lui attribue la nouvelle région' do
        expect(structure.region).to eql('Normandie')
      end
    end
  end

  describe 'à la création' do
    it 'programme un mail de relance' do
      expect { create :structure }
        .to have_enqueued_job(RelanceStructureSansCampagneJob).exactly(1)
    end
  end

  describe 'validation du champ siret' do
    context 'quand il est vide' do
      let(:structure) { build :structure }

      before { structure.valid? }

      it { expect(structure.errors[:siret]).to be_blank }
    end

    describe 'pour une nouvelle structure' do
      context 'quand il est un siret valide avec des espaces (14 chiffres)' do
        let(:structure) { build :structure, siret: '1234567890 1234' }

        before { structure.valid? }

        it do
          expect(structure.errors[:siret]).to be_blank
          expect(structure.siret).to eq('12345678901234')
        end
      end

      context 'quand il est un siret valide avec des espaces (14 chiffres)' do
        let(:structure) { build :structure, siret: '1234567890 1234' }

        before { structure.valid? }

        it do
          expect(structure.errors[:siret]).to be_blank
          expect(structure.siret).to eq('12345678901234')
        end
      end

      context 'quand il est un siret invalide avec des lettres (14 lettres)' do
        let(:structure) { build :structure, siret: '1234567890ABCD' }

        before { structure.valid? }

        it do
          expect(structure.errors[:siret]).to be_present
        end
      end

      context 'quand il est un siret valide (14 chiffres)' do
        let(:structure) { build :structure, siret: '12345678901234' }

        before { structure.valid? }

        it { expect(structure.errors[:siret]).to be_blank }
      end

      context 'quand il est un siren (9 chiffres)' do
        let(:structure) { build :structure, siret: '123456789' }

        before { structure.valid? }

        it do
          expect(structure.errors[:siret])
            .to include(I18n.t('activerecord.errors.models.structure.attributes.siret.invalid'))
        end
      end

      context 'quand il est invalide (pas 14 chiffres)' do
        let(:structure) { build :structure, siret: '12345678' }

        before { structure.valid? }

        it do
          expect(structure.errors[:siret])
            .to include(I18n.t('activerecord.errors.models.structure.attributes.siret.invalid'))
        end
      end
    end

    describe 'pour une structure existante' do
      # On crée la structure avec un SIRET valide (14 chiffres)
      let(:structure) { create :structure, siret: '12345678901234' }

      context 'quand on modifie avec un siren valide (9 chiffres)' do
        before do
          structure.siret = '987654321'
          structure.valid?
        end

        it { expect(structure.errors[:siret]).to be_blank }
      end

      context 'quand on modifie avec un siret valide (14 chiffres)' do
        before do
          structure.siret = '98765432101234'
          structure.valid?
        end

        it { expect(structure.errors[:siret]).to be_blank }
      end

      context 'quand on modifie avec un siret invalide' do
        before do
          structure.siret = '12345678'
          structure.valid?
        end

        it do
          expect(structure.errors[:siret])
            .to include(I18n.t('activerecord.errors.models.structure.attributes.siret.invalid'))
        end
      end

      context 'quand on essaie de supprimer le SIRET' do
        before do
          structure.siret = ''
          structure.valid?
        end

        it do
          message_erreur = I18n.t(
            'activerecord.errors.models.structure.attributes.siret.cannot_be_removed'
          )
          expect(structure.errors[:siret]).to include(message_erreur)
        end

        it 'ne permet pas la mise à jour' do
          expect(structure.save).to be false
        end
      end

      context 'quand on essaie de mettre le SIRET à nil' do
        before do
          structure.siret = nil
          structure.valid?
        end

        it do
          message_erreur = I18n.t(
            'activerecord.errors.models.structure.attributes.siret.cannot_be_removed'
          )
          expect(structure.errors[:siret]).to include(message_erreur)
        end

        it 'ne permet pas la mise à jour' do
          expect(structure.save).to be false
        end
      end
    end
  end

  describe "vérification SIRET via API SIRENE" do
    let(:structure) { build(:structure, siret: "12345678901234") }

    context "à la création d'une nouvelle structure" do
      context "quand le SIRET est valide" do
        # Le mock global du client SIRENE retourne true par défaut

        it "vérifie le SIRET et met à jour le statut" do
          expect(structure.save).to be true
          expect(structure.statut_siret).to be true
          expect(structure.date_verification_siret).to be_present
        end

        it "permet la création de la structure" do
          expect(structure.save).to be true
        end
      end

      context "quand le SIRET est invalide" do
        before do
          # Surcharge le mock global pour retourner false et mettre à jour le statut
          allow(MiseAJourSiret).to receive(:new) do |structure|
            mise_a_jour = instance_double(MiseAJourSiret)
            allow(mise_a_jour).to receive(:verifie_et_met_a_jour) do
              structure.statut_siret = false
              structure.date_verification_siret = nil
              false
            end
            mise_a_jour
          end
        end

        it "ajoute une erreur sur le SIRET" do
          structure.save
          message_erreur = I18n.t("activerecord.errors.models.structure.attributes.siret.invalid")
          expect(structure.errors[:siret]).to include(message_erreur)
        end

        it "ne permet pas la création de la structure" do
          expect(structure.save).to be false
        end

        it "ne met pas à jour le statut SIRET" do
          structure.save
          expect(structure.statut_siret).to be false
        end
      end
    end

    context "lors de la mise à jour d'une structure existante" do
      context "quand la structure a un SIRET vérifié" do
        let!(:structure) do
          # On crée la structure avec le mock global qui retourne true
          structure = create(:structure, siret: "12345678901234")
          structure.update_columns(statut_siret: true, date_verification_siret: 1.day.ago)
          structure
        end

        context "quand le nouveau SIRET est valide" do
          before do
            structure.siret = "98765432101234"
            # Mock pour que MiseAJourSiret mette à jour réellement la structure
            mise_a_jour = instance_double(MiseAJourSiret)
            allow(MiseAJourSiret).to receive(:new).and_return(mise_a_jour)
            allow(mise_a_jour).to receive(:verifie_et_met_a_jour) do
              structure.statut_siret = true
              structure.date_verification_siret = Time.current
              structure.code_naf = "53.10Z"
              structure.idcc = [ "5516", "9999" ]
              true
            end
          end

          it "vérifie le nouveau SIRET" do
            structure.save
            expect(MiseAJourSiret).to have_received(:new).at_least(:once)
          end

          it "met à jour le statut et la date" do
            freeze_time = Time.zone.parse("2024-01-15 10:00:00")
            Timecop.freeze(freeze_time) do
              structure.save
              expect(structure.statut_siret).to be true
              expect(structure.date_verification_siret).to eq(freeze_time)
            end
          end

          it "permet la mise à jour" do
            expect(structure.save).to be true
          end
        end

        context "quand le nouveau SIRET est invalide" do
          before do
            structure.siret = "98765432101234"
            # Surcharge le mock global pour retourner false et mettre à jour le statut
            allow(MiseAJourSiret).to receive(:new) do |structure|
              mise_a_jour = instance_double(MiseAJourSiret)
              allow(mise_a_jour).to receive(:verifie_et_met_a_jour) do
                structure.statut_siret = false
                structure.date_verification_siret = nil
                false
              end
              mise_a_jour
            end
          end

          it "ajoute une erreur sur le SIRET" do
            structure.save
            message_erreur = I18n.t("activerecord.errors.models.structure.attributes.siret.invalid")
            expect(structure.errors[:siret]).to include(message_erreur)
          end

          it "ne permet pas la mise à jour" do
            expect(structure.save).to be false
          end
        end
      end

      context "quand la structure n'a pas de SIRET vérifié" do
        let!(:structure) do
          # On crée la structure avec le mock global qui retourne true
          structure = create(:structure, siret: "12345678901234")
          structure.update_columns(statut_siret: false, date_verification_siret: nil)
          structure
        end

        context "quand le nouveau SIRET est valide" do
          before do
            structure.siret = "98765432101234"
            # Mock pour que MiseAJourSiret mette à jour réellement la structure
            mise_a_jour = instance_double(MiseAJourSiret)
            allow(MiseAJourSiret).to receive(:new).and_return(mise_a_jour)
            allow(mise_a_jour).to receive(:verifie_et_met_a_jour) do
              structure.statut_siret = true
              structure.date_verification_siret = Time.current
              structure.code_naf = "53.10Z"
              structure.idcc = [ "5516", "9999" ]
              true
            end
          end

          it "vérifie le SIRET" do
            structure.save
            expect(MiseAJourSiret).to have_received(:new).at_least(:once)
          end

          it "met à jour le statut et la date" do
            structure.save
            expect(structure.statut_siret).to be true
            expect(structure.date_verification_siret).to be_present
          end

          it "permet la mise à jour même si le SIRET n'est pas vérifié" do
            expect(structure.save).to be true
          end
        end

        context "quand le nouveau SIRET est invalide" do
          before do
            structure.siret = "98765432101234"
            # Surcharge le mock global pour retourner false et mettre à jour le statut
            allow(MiseAJourSiret).to receive(:new) do |structure|
              mise_a_jour = instance_double(MiseAJourSiret)
              allow(mise_a_jour).to receive(:verifie_et_met_a_jour) do
                structure.statut_siret = false
                structure.date_verification_siret = nil
                false
              end
              mise_a_jour
            end
          end

          it "ne bloque pas la mise à jour" do
            expect(structure.save).to be true
          end

          it "ne met pas à jour le statut SIRET" do
            structure.save
            expect(structure.statut_siret).to be false
          end
        end
      end
    end

    context "quand le SIRET n'est pas modifié" do
      let!(:structure) do
        # On crée la structure avec le mock global qui retourne true
        structure = create(:structure, siret: "12345678901234")
        structure.update_columns(statut_siret: true, date_verification_siret: 1.day.ago)
        structure
      end

      before do
        # Réinitialise les mocks pour ce test spécifique
        RSpec::Mocks.space.proxy_for(MiseAJourSiret).reset
        allow(MiseAJourSiret).to receive(:new).and_call_original
      end

      it "ne relance pas la vérification" do
        structure.nom = "Nouveau nom"
        structure.save
        expect(MiseAJourSiret).not_to have_received(:new)
      end
    end
  end

  describe 'unicité du SIRET' do
    context 'quand un SIRET identique existe avec des espaces' do
      # Test spécifique pour vérifier que la normalisation des espaces fonctionne
      # avant la validation d'unicité
      let!(:structure_existante) { create :structure, siret: '83386447300016' }
      let(:nouvelle_structure) { build :structure, siret: '833 864 473 00016' }

      before { nouvelle_structure.valid? }

      it 'ajoute une erreur après normalisation' do
        message_erreur = I18n.t('activerecord.errors.models.structure.attributes.siret.taken')
        expect(nouvelle_structure.errors[:siret]).to include(message_erreur)
      end
    end

    context 'avec des structures soft-deleted' do
      # Test spécifique pour vérifier que acts_as_paranoid exclut les structures
      # supprimées de la validation d'unicité
      let!(:structure_supprimee) do
        structure = create :structure, siret: '83386447300016'
        structure.destroy
        structure
      end
      let(:nouvelle_structure) { build :structure, siret: '83386447300016' }

      it 'ne bloque pas la création (les structures supprimées sont exclues)' do
        expect(nouvelle_structure.save).to be true
      end
    end

    context 'quand le SIRET est invalide ET déjà utilisé' do
      context 'avec un SIRET trop court (8 chiffres) qui existe déjà' do
        let!(:structure_existante) do
          structure = build(:structure, siret: '12345678')
          structure.save(validate: false)
          structure
        end
        let(:nouvelle_structure) { build :structure, siret: '12345678' }

        before { nouvelle_structure.valid? }

        it 'affiche uniquement le message "invalid", pas le message d\'unicité' do
          message_invalid = I18n.t('activerecord.errors.models.structure.attributes.siret.invalid')
          message_taken = I18n.t('activerecord.errors.models.structure.attributes.siret.taken')

          expect(nouvelle_structure.errors[:siret]).to include(message_invalid)
          expect(nouvelle_structure.errors[:siret]).not_to include(message_taken)
          expect(nouvelle_structure.errors[:siret].size).to eq(1)
        end
      end

      context 'avec un SIRET de 9 chiffres (interdit pour nouvelle structure) qui existe déjà' do
        let!(:structure_existante) do
          structure = build(:structure, siret: '123456789')
          structure.save(validate: false)
          structure
        end
        let(:nouvelle_structure) { build :structure, siret: '123456789' }

        before { nouvelle_structure.valid? }

        it 'affiche uniquement le message "invalid", pas le message d\'unicité' do
          message_invalid = I18n.t('activerecord.errors.models.structure.attributes.siret.invalid')
          message_taken = I18n.t('activerecord.errors.models.structure.attributes.siret.taken')

          expect(nouvelle_structure.errors[:siret]).to include(message_invalid)
          expect(nouvelle_structure.errors[:siret]).not_to include(message_taken)
          expect(nouvelle_structure.errors[:siret].size).to eq(1)
        end
      end
    end
  end

  describe '#admins' do
    let(:structure) { create :structure_locale }
    let(:compte) { create :compte_conseiller, structure: structure }
    let!(:compte_admin) { create :compte_admin, nom: "admin 1", structure: structure }
    let!(:compte_admin2) { create :compte_admin, nom: "admin 2", structure: structure }
    let!(:compte_admin_refuse) { create :compte_admin, :refusee, structure: structure }
    let!(:compte_superadmin) { create :compte_superadmin, nom: "superadmin",  structure: structure }
    let(:autre_structure) { create :structure }
    let!(:autre_admin) { create :compte_admin, structure: autre_structure }

    it "trouve les admins d'une structure" do
      expect(structure.admins.pluck(:nom)).to contain_exactly("admin 1", "admin 2", "superadmin")
    end
  end

  describe "relations OPCO" do
    let(:structure) { create(:structure_locale) }
    let(:opco1) { create(:opco, nom: "OPCO 1") }
    let(:opco2) { create(:opco, nom: "OPCO 2") }

    it "peut avoir plusieurs OPCOs" do
      structure.opcos << [ opco1, opco2 ]

      expect(structure.opcos.count).to eq(2)
      expect(structure.opcos.to_a).to contain_exactly(opco1, opco2)
    end

    it "peut supprimer un OPCO" do
      structure.opcos << [ opco1, opco2 ]
      structure.opcos.delete(opco1)

      expect(structure.opcos.count).to eq(1)
      expect(structure.opcos.first).to eq(opco2)
    end

    it "supprime les affiliations quand la structure est supprimée" do
      structure.opcos << opco1
      structure_id = structure.id

      structure.destroy

      expect(StructureOpco.where(structure_id: structure_id)).to be_empty
    end

    describe "#opco_id" do
      context "quand la structure a un OPCO" do
        before { structure.opcos << opco1 }

        it "retourne l'ID du premier OPCO" do
          expect(structure.opco_id).to eq(opco1.id)
        end
      end

      context "quand la structure a plusieurs OPCOs" do
        before { structure.opcos << [ opco1, opco2 ] }

        it "retourne l'ID du premier OPCO" do
          expect(structure.opco_id).to eq(opco1.id)
        end
      end

      context "quand la structure n'a pas d'OPCO" do
        it "retourne nil" do
          expect(structure.opco_id).to be_nil
        end
      end
    end

    describe "#opco_id=" do
      context "quand on assigne un ID d'OPCO valide" do
        it "associe l'OPCO à la structure" do
          structure.opco_id = opco1.id
          structure.save

          expect(structure.opcos.count).to eq(1)
          expect(structure.opcos.first).to eq(opco1)
        end

        it "remplace les OPCOs existants" do
          structure.opcos << opco2
          structure.opco_id = opco1.id
          structure.save

          expect(structure.opcos.count).to eq(1)
          expect(structure.opcos.first).to eq(opco1)
        end
      end

      context "quand on assigne nil" do
        before { structure.opcos << opco1 }

        it "supprime tous les OPCOs" do
          structure.opco_id = nil
          structure.save

          expect(structure.opcos.count).to eq(0)
        end
      end

      context "quand on assigne une chaîne vide" do
        before { structure.opcos << opco1 }

        it "supprime tous les OPCOs" do
          structure.opco_id = ""
          structure.save

          expect(structure.opcos.count).to eq(0)
        end
      end
    end
  end
end
