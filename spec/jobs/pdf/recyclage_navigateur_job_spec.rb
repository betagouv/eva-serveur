require 'rails_helper'

describe Pdf::RecyclageNavigateurJob, type: :job do
  describe '#perform' do
    it 'redémarre le navigateur Chromium partagé' do
      allow(Pdf::Navigateur).to receive(:redemarre!)

      described_class.perform_now

      expect(Pdf::Navigateur).to have_received(:redemarre!)
    end
  end
end
