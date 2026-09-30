require 'rails_helper'

describe 'reviewapp:seed' do
  include_context 'rake'

  let(:mot_de_passe_chiffre) { '$2a$11$abcdefghijklmnopqrstuuJ8Zc1Yk3n5o7q9s1u3w5y7A9C1E3G5I' }
  let!(:compte) { create :compte }
  let!(:mot_de_passe_initial) { compte.encrypted_password }

  before do
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with('APP').and_return(app)
    allow(ENV).to receive(:fetch).and_call_original
    allow(ENV).to receive(:fetch).with('MOT_DE_PASS_COMPTES_PREPROD_ENCRYPTE')
                                 .and_return(mot_de_passe_chiffre)
  end

  context 'en production' do
    let(:app) { 'eva-serveur' }

    it 'refuse de remplacer les mots de passe' do
      expect { subject.invoke }.to raise_error(SystemExit)
                               .and output(/production/).to_stderr
      expect(compte.reload.encrypted_password).to eq mot_de_passe_initial
    end
  end

  context 'en préproduction' do
    let(:app) { 'eva-serveur-preprod' }

    it 'remplace les mots de passe' do
      subject.invoke
      expect(compte.reload.encrypted_password).to eq mot_de_passe_chiffre
    end
  end

  context 'sur une review app' do
    let(:app) { 'eva-serveur-preprod-pr1234' }

    it 'remplace les mots de passe' do
      subject.invoke
      expect(compte.reload.encrypted_password).to eq mot_de_passe_chiffre
    end
  end
end
