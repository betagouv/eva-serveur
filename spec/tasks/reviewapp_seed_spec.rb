require 'rails_helper'

describe 'reviewapp:seed' do
  include_context 'rake'

  let(:mot_de_passe) { 'mot-de-passe-preprod' }
  let!(:compte) { create :compte }
  let!(:mot_de_passe_initial) { compte.encrypted_password }

  before do
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with('APP').and_return(app)
    allow(ENV).to receive(:fetch).and_call_original
    allow(ENV).to receive(:fetch).with('MOT_DE_PASS_COMPTES_PREPROD')
                                 .and_return(mot_de_passe)
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
      expect(compte.reload.valid_password?(mot_de_passe)).to be true
    end
  end

  context 'sur une review app' do
    let(:app) { 'eva-serveur-preprod-pr1234' }

    it 'remplace les mots de passe' do
      subject.invoke
      expect(compte.reload.valid_password?(mot_de_passe)).to be true
    end
  end
end
