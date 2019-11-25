# frozen_string_literal: true

require 'rails_helper'

describe Partie do
  let(:partie) { described_class.new session_id: 'session_id' }

  it { should validate_presence_of(:session_id) }
  it { should belong_to(:evaluation) }
  it { should belong_to(:situation) }

  context 'peut récupérer la restitution' do
    let(:restitution) { double }

    before do
      expect(FabriqueRestitution).to receive(:depuis_session_id)
        .with('session_id').and_return restitution
    end

    it { expect(partie.restitution).to eq restitution }
  end
end
