require 'rails_helper'

describe StructureMailer, type: :mailer do
  let(:id) { SecureRandom.uuid }
  let(:structure) { StructureLocale.new nom: 'Ma Super Structure', id: id, code_postal: '75012' }
  let(:compte) { Compte.new prenom: 'Paule', email: 'debut@test.com', structure: structure }

  describe '#nouvelle_structure' do
    it "envoie un email pour informer de la création d'une structure" do
      email = described_class.with(compte: compte, structure: structure).nouvelle_structure

      assert_emails 1 do
        email.deliver_now
      end

      expect(email.from).to eql([ Eva::EMAIL_CONTACT ])
      expect(email.to).to eql([ 'debut@test.com' ])
      expect(email.subject).to eql('Création de « Ma Super Structure - 75012 »')
      expect(email.multipart?).to be(false)
      expect(email.body).to include('Paule')
      expect(email.body).to include('Ma Super Structure - 75012')
      expect(email.body).to include('Besoin d&#39;aide')
      expect(email.body).to include(Eva::DOCUMENT_PRISE_EN_MAIN)
      expect(email.body).to include("http://test.com/admin/sign_up?structure_id=#{id}")
    end
  end

  describe '#relance_creation_campagne' do
    it 'envoie un email de relance pour inciter à créer une campagne' do
      email = described_class.with(compte_admin: compte).relance_creation_campagne

      assert_emails 1 do
        email.deliver_now
      end

      expect(email.from).to eql([ Eva::EMAIL_CONTACT ])
      expect(email.to).to eql([ 'debut@test.com' ])
      expect(email.subject).to eql('Eva - Et si vous testiez les compétences avec des jeux ?')
      expect(email.body).to include('Paule')
      expect(email.body).to include('Ma Super Structure - 75012')
      expect(email.body).to include('Créez votre première campagne')
      expect(email.body).to include('http://test.com/admin/campagnes/new')
    end
  end

  describe "#invitation_structure" do
    let(:id) { SecureRandom.uuid }
    let(:structure) { StructureLocale.new nom: "Ma Super Structure", id: id, code_postal: "75012" }
    let(:invitant) {
 Compte.new prenom: "Camille", nom: "Martin", email: "camille@test.com", structure: structure }

    context "quand un message personnalisé est fourni" do
      let(:mail) do
        described_class.with(
          invitant: invitant,
          structure: structure,
          email_destinataire: "invite@test.com",
          message_personnalise: "Bienvenue dans l'équipe."
        ).invitation_structure
      end

      it "envoie un email d'invitation complet" do
        assert_emails 1 do
          mail.deliver_now
        end

        expect(mail.from).to eql([ Eva::EMAIL_CONTACT ])
        expect(mail.to).to eql([ "invite@test.com" ])
        expect(mail.subject).to eql("Vous êtes invité(e) à rejoindre Ma Super Structure - 75012")
        expect(mail.body).to include(
          "Camille Martin vous invite à rejoindre Ma Super Structure\u00a0-\u00a075012 sur EVA."
        )
        expect(mail.body).to include("Bienvenue dans l&#39;équipe.")
        expect(mail.body).to include("Rejoindre la structure")
        expect(mail.body).to include("http://test.com/admin/sign_up?structure_id=#{id}")
      end
    end

    context "quand aucun message personnalisé n'est fourni" do
      let(:mail) do
        described_class.with(
          invitant: invitant,
          structure: structure,
          email_destinataire: "invite@test.com",
          message_personnalise: ""
        ).invitation_structure
      end

      it "n'affiche pas de paragraphe de message personnalisé" do
        mail.deliver_now

        expect(mail.body).not_to include("Bienvenue dans l'équipe.")
      end
    end
  end
end
