require 'rails_helper'

describe 'reviewapp:initdb' do
  include_context 'rake'

  let(:connexion) { ActiveRecord::Base.connection }

  before do
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with('APP').and_return(app)
    allow(File).to receive(:read).and_call_original
    allow(File).to receive(:read).with('db/evaluations_tests.sql').and_return("SELECT 1;\n")
    allow(connexion).to receive(:execute).and_call_original
  end

  context 'en production' do
    let(:app) { 'eva-serveur' }

    it "refuse d'exécuter le dump" do
      expect { subject.invoke }.to raise_error(SystemExit)
                               .and output(/production/).to_stderr
      expect(connexion).not_to have_received(:execute).with('SELECT 1')
    end
  end

  context 'en préproduction' do
    let(:app) { 'eva-serveur-preprod' }

    it 'exécute le dump' do
      subject.invoke
      expect(connexion).to have_received(:execute).with('SELECT 1')
    end
  end

  context 'sur une review app' do
    let(:app) { 'eva-serveur-preprod-pr1234' }

    it 'exécute le dump' do
      subject.invoke
      expect(connexion).to have_received(:execute).with('SELECT 1')
    end
  end
end
