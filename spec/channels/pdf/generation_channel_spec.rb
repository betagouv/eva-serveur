require 'rails_helper'

describe Pdf::GenerationChannel, type: :channel do
  let(:mon_compte) { create :compte }

  describe '#subscribed' do
    it "s'abonne au canal quand le jeton correspond au compte connecté" do
      stub_connection(current_compte: mon_compte)
      token = Pdf::GenerationToken.genere(mon_compte.id)

      subscribe(token: token)

      expect(subscription).to be_confirmed
      expect(subscription).to have_stream_from(described_class.canal(token))
    end

    it "rejette l'abonnement quand le jeton appartient à un autre compte" do
      autre_compte = create :compte
      stub_connection(current_compte: mon_compte)
      token = Pdf::GenerationToken.genere(autre_compte.id)

      subscribe(token: token)

      expect(subscription).to be_rejected
    end

    it "rejette l'abonnement pour un jeton invalide" do
      stub_connection(current_compte: mon_compte)

      subscribe(token: 'jeton-invalide')

      expect(subscription).to be_rejected
    end
  end
end
