# frozen_string_literal: true

require 'rails_helper'

describe CampagneMailer, type: :mailer do
  describe 'relance' do
    let(:structure) { Structure.new nom: 'Ma Super Structure' }
    let(:compte) { Compte.new prenom: 'Paule', email: 'debut@test.com', structure: structure }
    let(:campagne) { Campagne.new compte: compte }
    let(:mail) { CampagneMailer.with(campagne: campagne).relance }

    it 'renders the headers' do
      expect(mail.subject).to eq(
        'Paule, quelques conseils pour démarrer sur eva - Positionnement des compétences'
      )
      expect(mail.to).to eq(['debut@test.com'])
      expect(mail.from).to eql([Eva::EMAIL_CONTACT])
    end
  end
end
