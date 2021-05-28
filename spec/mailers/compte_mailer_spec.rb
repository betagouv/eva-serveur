# frozen_string_literal: true

require 'rails_helper'

describe CompteMailer, type: :mailer do
  describe '#nouveau_compte' do
    it 'envoie un email de confirmation de création de compte' do
      structure = Structure.new nom: 'Ma Super Structure'
      compte = Compte.new prenom: 'Paule', email: 'debut@test.com', structure: structure

      email = CompteMailer.with(compte: compte).nouveau_compte

      assert_emails 1 do
        email.deliver_now
      end

      expect(email.from).to eql([Eva::EMAIL_CONTACT])
      expect(email.to).to eql(['debut@test.com'])
      expect(email.subject).to eql('Votre accès eva à « Ma Super Structure »')
      expect(email.multipart?).to be(false)
      expect(email.body).to include('Paule')
      expect(email.body).to include('debut@test.com')
      expect(email.body).to include('Ma Super Structure')
      expect(email.body).to include('Besoin d&#39;aide')
      expect(email.body).to include(Eva::DOCUMENT_PRISE_EN_MAIN)
    end
  end

  describe 'relance' do
    let(:structure) { Structure.new nom: 'Ma Super Structure' }
    let(:compte) { Compte.new prenom: 'Paule', email: 'debut@test.com', structure: structure }
    let(:mail) { CompteMailer.with(compte: compte).relance }

    it 'renders the headers' do
      expect(mail.subject).to eq(
        'Paule, quelques conseils pour démarrer sur eva - Positionnement des compétences'
      )
      expect(mail.to).to eq(['debut@test.com'])
      expect(mail.from).to eql([Eva::EMAIL_CONTACT])
    end
  end
end
