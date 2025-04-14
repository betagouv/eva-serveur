# frozen_string_literal: true

require 'rails_helper'

describe CompteMailer, type: :mailer do
  describe '#nouveau_compte' do
    it 'envoie un email de confirmation de création de compte' do
      structure = StructureLocale.new nom: 'Ma Super Structure', code_postal: '75012'
      compte = Compte.new prenom: 'Paule', email: 'debut@test.com', structure: structure

      email = described_class.with(compte: compte).nouveau_compte

      assert_emails 1 do
        email.deliver_now
      end

      expect(email.from).to eql([ Eva::EMAIL_CONTACT ])
      expect(email.to).to eql([ 'debut@test.com' ])
      expect(email.subject).to eql('Votre accès eva à « Ma Super Structure - 75012 »')
      expect(email.multipart?).to be(false)
      expect(email.body).to include('Paule')
      expect(email.body).to include('debut@test.com')
      expect(email.body).to include('Ma Super Structure - 75012')
      expect(email.body).to include('Besoin d&#39;aide')
      expect(email.body).to include(Eva::DOCUMENT_PRISE_EN_MAIN)
    end
  end

  describe '#alerte_admin' do
    it "envoie un email de demande de validation d'un nouveau compte à l'admin" do
      structure = StructureLocale.new id: SecureRandom.uuid, nom: 'Ma Super Structure',
                                      code_postal: '75012'
      admin = Compte.new prenom: 'Admin',
                         email: 'debut@test.com',
                         role: :admin,
                         structure: structure
      compte = Compte.new prenom: 'Paule',
                          nom: 'Delaporte',
                          email: 'debut@test.com',
                          structure: structure,
                          id: SecureRandom.uuid
      email = described_class.with(compte: compte, compte_admin: admin)
                             .alerte_admin

      assert_emails 1 do
        email.deliver_now
      end

      expect(email.from).to eql([ Eva::EMAIL_CONTACT ])
      expect(email.to).to eql([ 'debut@test.com' ])
      expect(email.subject).to eql("Validez l'accès eva à « Ma Super Structure - 75012 » " \
                                   'de vos collègues')
      expect(email.multipart?).to be(false)
      expect(email.body).to include('Admin')
      expect(email.body).to include('Paule Delaporte')
      expect(email.body).to include('Ma Super Structure - 75012')
      expect(email.body).to include(admin_structure_locale_url(compte.structure))
    end
  end

  describe 'relance' do
    let(:structure) { StructureLocale.new nom: 'Ma Super Structure', code_postal: '75012' }
    let(:compte) { Compte.new prenom: 'Paule', email: 'debut@test.com', structure: structure }
    let(:mail) { described_class.with(compte: compte).relance }

    it 'renders the headers' do
      expect(mail.subject).to eq(
        'Paule, quelques ressources pour vous aider à réaliser vos premières évaluations'
      )
      expect(mail.to).to eq([ 'debut@test.com' ])
      expect(mail.from).to eql([ Eva::EMAIL_CONTACT ])
    end
  end
end
