require 'rails_helper'

describe 'reviewapp:videdb' do
  include_context 'rake'

  let(:connexion) { ActiveRecord::Base.connection }

  before do
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with('APP').and_return(app)
    allow(connexion).to receive(:tables).and_return(%w[comptes schema_migrations])
    allow(connexion).to receive(:execute).and_call_original
    allow(connexion).to receive(:execute).with(/\ADROP TABLE/)
  end

  context 'en production' do
    let(:app) { 'eva-serveur' }

    it 'refuse de vider la base' do
      expect { subject.invoke }.to raise_error(SystemExit)
                               .and output(/eva-serveur-preprod/).to_stderr
      expect(connexion).not_to have_received(:execute).with(/\ADROP TABLE/)
    end
  end

  context 'sur une review app' do
    let(:app) { 'eva-serveur-preprod-pr1234' }

    it 'refuse de vider la base' do
      expect { subject.invoke }.to raise_error(SystemExit)
                               .and output(/eva-serveur-preprod/).to_stderr
      expect(connexion).not_to have_received(:execute).with(/\ADROP TABLE/)
    end
  end

  context 'en préproduction' do
    let(:app) { 'eva-serveur-preprod' }

    it 'supprime toutes les tables' do
      subject.invoke
      expect(connexion).to have_received(:execute)
        .with('DROP TABLE "comptes", "schema_migrations" CASCADE')
    end
  end
end
