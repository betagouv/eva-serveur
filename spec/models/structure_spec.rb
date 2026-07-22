require 'rails_helper'

describe Structure, type: :model do
  describe "dependent invitations" do
    it "supprime les invitations quand la structure est supprimée" do
      structure = create(:structure_locale, :avec_admin)
      invitation = create(
        :invitation,
        structure: structure,
        invitant: create(:compte_admin, structure: structure)
      )

      expect { structure.destroy }.not_to raise_error
      expect(Invitation.where(id: invitation.id)).not_to exist
    end
  end

  it { is_expected.to validate_presence_of(:nom) }
  it { is_expected.to validate_uniqueness_of(:nom).scoped_to(:code_postal).case_insensitive }
  it { is_expected.to validate_numericality_of(:siret) }

  describe 'Ancestry primary key format' do
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

  def mock_geo_api(code_postal, code_commune, region, lat: 48.0, lon: 2.0)
    mock_reponse_typhoeus(
      "https://geo.api.gouv.fr/communes?codePostal=#{code_postal}&fields=code,centre,region",
      [ { code: code_commune,
          centre: { type: 'Point', coordinates: [ lon, lat ] },
          region: { nom: region } } ]
    )
  end

  describe 'géolocalisation à la validation' do
    describe "pour n'importe quel code postal" do
      let(:structure) { described_class.new code_postal: '75012' }

      before do
        mock_geo_api("75012", "75123", 'Île-de-France', lat: 48.8566, lon: 2.3522)
        structure.valid?
      end

      it do
        expect(structure.region).to eql('Île-de-France')
        expect(structure.code_commune).to eql("75123")
      end
    end

    describe 'si ma structure a un code postal commençant par 988' do
      let(:structure) { described_class.new code_postal: '98850' }

      before do
        mock_geo_api("98850", "", 'Nouvelle-Calédonie')
        structure.valid?
      end

      it 'lui attribue la région Nouvelle-Calédonie' do
        expect(structure.region).to eql('Nouvelle-Calédonie')
      end
    end

    describe 'si ma structure a un code postal commençant par 20' do
      let(:structure) { described_class.new code_postal: '20090' }

      before do
        mock_geo_api("20090", "", 'Corse')
        structure.valid?
      end

      it 'lui attribue la région Corse' do
        expect(structure.region).to eql('Corse')
      end
    end

    context 'quand ma structure a déjà une région et un code commune' do
      let(:structure) {
 described_class.new code_postal: '20114', region: 'Corse', code_commune: '12123' }

      before do
        structure.code_postal = '61000'
        mock_geo_api("61000", "61123", 'Normandie')
        structure.valid?
      end

      it 'écrase les anciennes valeurs' do
        expect(structure.region).to eql('Normandie')
        expect(structure.code_commune).to eql("61123")
      end
    end
  end

  describe '#code_commune' do
    context 'quand le code commune est absent' do
      let(:structure) { create :structure, code_postal: '75012' }

      before do
        structure.update_columns(code_commune: nil)
        mock_geo_api('75012', '75056', 'Île-de-France', lat: 48.8566, lon: 2.3522)
      end

      it 'géolocalise et sauvegarde avant de retourner le code commune' do
        expect(structure).to receive(:geocodifie).once.and_call_original
        expect(structure.code_commune).to eql('75056')
        expect(structure.reload.code_commune).to eql('75056')
      end
    end

    context 'quand le code commune est déjà présent' do
      let(:structure) { create :structure, code_commune: '75056' }

      it 'le retourne sans appeler geocodifie' do
        expect(structure).not_to receive(:geocodifie)
        expect(structure.code_commune).to eql('75056')
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
        end

        it do
          structure.valid?
          message_erreur = I18n.t(
            'activerecord.errors.models.structure.attributes.siret.cannot_be_removed'
          )
          expect(structure.errors[:siret]).to include(message_erreur)
        end

        it "c'est accepté pour l'annonymisation" do
          structure.anonymise_le = Time.zone.now
          expect(structure.save).to be true
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

    context "quand un doublon SIRET existe déjà en base (données historiques)" do
      let!(:structure_principale) { create(:structure_locale, siret: 999_999_999_999_99) }
      let!(:autre_fiche) { create(:structure_locale, siret: 888_888_888_888_88) }

      before { autre_fiche.update_columns(siret: structure_principale.siret) }

      it "permet de sauvegarder sans changer le SIRET (pas de re-vérification :taken)" do
        structure_principale.nom = "Nom mis à jour"
        expect(structure_principale.save).to be true
        expect(structure_principale.errors[:siret]).to be_blank
      end
    end

    context 'quand le bypass est activé via current_ability' do
      let!(:structure_existante) do
        structure = build(:structure, siret: '12345678901234')
        structure.save(validate: false)
        structure
      end

      let(:nouvelle_structure) { build(:structure, siret: '12345678901234') }

      before do
        stub_ability = instance_double(Ability)
        allow(stub_ability).to receive(:compte).and_return(nil)
        allow(stub_ability).to receive(:can?).with(:bypass_siret_uniqueness,
                                                   nouvelle_structure).and_return(true)

        nouvelle_structure.current_ability = stub_ability
        nouvelle_structure.valid?
      end


      it 'ignore la validation d’unicité et ne renvoie pas d’erreur :taken' do
        message_taken = I18n.t('activerecord.errors.models.structure.attributes.siret.taken')
        expect(nouvelle_structure.errors[:siret]).not_to include(message_taken)
      end

      it 'la structure reste valide' do
        expect(nouvelle_structure).to be_valid
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

  describe '#est_une_structure_ocpo?' do
    let(:opco) { build_stubbed(:opco) }

    context 'quand la structure a un type Ocpco' do
      let(:structure) { build_stubbed(:structure_opco, opco: opco) }

      it 'retourne true' do
        expect(structure.est_une_structure_ocpo?).to be true
      end
    end

    context "quand la structure a un autre type" do
      let(:structure) { build_stubbed(:structure_administrative) }

      it 'retourne false' do
        expect(structure.est_une_structure_ocpo?).to be false
      end
    end
  end

  describe "relation OPCO" do
    let(:structure) { create(:structure_locale) }
    let(:opco1) { create(:opco, nom: "OPCO 1") }
    let(:opco2) { create(:opco, nom: "OPCO 2") }

    it "a au plus un OPCO (belongs_to :opco)" do
      structure.update!(opco: opco1)

      expect(structure.opco).to eq(opco1)
      expect(structure.opco_id).to eq(opco1.id)
    end

    describe "#opco_id" do
      context "quand la structure a un OPCO" do
        before { structure.update!(opco: opco1) }

        it "retourne l'ID de l'OPCO" do
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

          expect(structure.reload.opco).to eq(opco1)
        end

        it "remplace l'OPCO existant" do
          structure.update!(opco: opco2)
          structure.opco_id = opco1.id
          structure.save

          expect(structure.reload.opco).to eq(opco1)
        end
      end

      context "quand on assigne nil" do
        before { structure.update!(opco: opco1) }

        it "détache l'OPCO" do
          structure.opco_id = nil
          structure.save

          expect(structure.reload.opco).to be_nil
        end
      end

      context "quand on assigne une chaîne vide" do
        before { structure.update!(opco: opco1) }

        it "détache l'OPCO" do
          structure.opco_id = ""
          structure.save

          expect(structure.reload.opco).to be_nil
        end
      end
    end

    describe "#opco_financeur" do
      it "retourne l'OPCO quand il est financeur" do
        opco1.update!(financeur: true)
        structure.update!(opco: opco1)

        expect(structure.opco_financeur).to eq(opco1)
      end

      it "retourne nil quand l'OPCO n'est pas financeur" do
        opco1.update!(financeur: false)
        structure.update!(opco: opco1)

        expect(structure.opco_financeur).to be_nil
      end
    end
  end

  describe "champs contact (email_contact, telephone)" do
    context "email_contact" do
      it "accepte un email valide" do
        structure = build(:structure, email_contact: "contact@structure.fr")
        expect(structure).to be_valid
      end

      it "accepte blank" do
        structure = build(:structure, email_contact: nil)
        expect(structure).to be_valid
      end

      it "refuse un format invalide" do
        structure = build(:structure, email_contact: "pas-un-email")
        expect(structure).not_to be_valid
        expect(structure.errors[:email_contact]).to be_present
      end

      it "n'ajoute qu'une erreur invalid pour un format invalide et ne vérifie pas le DNS" do
        structure = build(:structure, email_contact: "pas-un-email")
        allow(structure).to receive(:email_contact_changed?).and_return(true)

        structure.valid?

        invalid_errors = structure.errors.details[:email_contact].count { |error|
 error[:error] == :invalid }
        expect(invalid_errors).to eq(1)
        expect(Truemail).not_to have_received(:valid?).with("pas-un-email")
      end

      context "validation Truemail (vérification DNS / boîte mail)" do
        let(:structure) { build(:structure, email_contact: "contact@structure.fr") }

        before do
          allow(structure).to receive(:email_contact_changed?).and_return(true)
          allow(Truemail).to receive(:valid?).and_return(true)
        end

        it "n'ajoute pas d'erreur quand Truemail valide l'email" do
          structure.valid?
          expect(structure.errors[:email_contact]).to be_blank
        end

        it "ajoute une erreur quand Truemail invalide l'email" do
          allow(Truemail).to receive(:valid?).with("contact@structure.fr").and_return(false)
          structure.valid?
          expect(structure.errors[:email_contact]).to be_present
        end

        it "ne appelle pas Truemail quand l'email n'a pas changé" do
          allow(structure).to receive(:email_contact_changed?).and_return(false)
          structure.valid?
          expect(Truemail).not_to have_received(:valid?).with("contact@structure.fr")
        end
      end
    end

    context "telephone" do
      it "accepte un numéro avec chiffres et espaces" do
        structure = build(:structure, telephone: "(+33) 1 22 33 44 55")
        expect(structure).to be_valid
      end

      it "accepte blank" do
        structure = build(:structure, telephone: nil)
        expect(structure).to be_valid
      end

      it "refuse des caractères non autorisés" do
        structure = build(:structure, telephone: "06ab123456")
        expect(structure).not_to be_valid
        expect(structure.errors[:telephone]).to be_present
      end
    end
  end
end
