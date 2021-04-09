# frozen_string_literal: true

require 'rails_helper'

describe CompteMailer, type: :mailer do
  it 'envoie un email de confirmation de création de compte' do
    structure = Structure.new nom: 'Ma Super Structure'
    compte = Compte.new prenom: 'Paule', email: 'debut@test.com', structure: structure
    campagne = Campagne.new compte: compte, libelle: 'Paris 2019', code: 'paris2019'

    email = CompteMailer.with(campagne: campagne).nouveau_compte

    assert_emails 1 do
      email.deliver_now
    end

    expect(email.from).to eql([Eva::EMAIL_CONTACT])
    expect(email.to).to eql(['debut@test.com'])
    expect(email.subject).to eql('Votre accès eva à « Ma Super Structure »')
    expect(email.multipart?).to be(false)
    expect(email.body.decoded).to include('Paule')
    expect(email.body.encoded).to include('debut@test.com')
    expect(email.body.encoded).to include('Ma Super Structure')
    expect(email.body.encoded).to include('paris2019')
  end
end
