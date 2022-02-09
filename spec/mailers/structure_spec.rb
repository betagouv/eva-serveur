# frozen_string_literal: true

require 'rails_helper'

describe StructureMailer, type: :mailer do
  describe '#nouvelle_structure' do
    it "envoie un email pour informer de la création d'une structure" do
      id = SecureRandom.uuid
      structure = StructureLocale.new nom: 'Ma Super Structure', id: id, code_postal: '75012'
      compte = Compte.new prenom: 'Paule', email: 'debut@test.com', structure: structure

      email = StructureMailer.with(compte: compte, structure: structure).nouvelle_structure

      assert_emails 1 do
        email.deliver_now
      end

      expect(email.from).to eql([Eva::EMAIL_CONTACT])
      expect(email.to).to eql(['debut@test.com'])
      expect(email.subject).to eql('Création de « Ma Super Structure - 75012 »')
      expect(email.multipart?).to be(false)
      expect(email.body).to include('Paule')
      expect(email.body).to include('Ma Super Structure - 75012')
      expect(email.body).to include('Besoin d&#39;aide')
      expect(email.body).to include(Eva::DOCUMENT_PRISE_EN_MAIN)
      expect(email.body).to include("http://test.com/pro/admin/sign_up?structure_id=#{id}")
    end
  end
end
