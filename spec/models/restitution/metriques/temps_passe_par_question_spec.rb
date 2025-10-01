require 'rails_helper'

RSpec.describe Restitution::Metriques::TempsPasseParQuestion do
  let(:service) { described_class.new(evenements) }
  let(:partie) { create :partie }
  let(:evenements) { partie.evenements }

  describe '#calculer' do
    context "quand il n'y a pas d'evenements" do
      let(:evenements) { [] }

      it 'returns {}' do
        expect(service.calculer).to eq({})
      end
    end

    context 'quand les evenements sont groupés par questions' do
      before do
        create(:evenement, date: 10.minutes.ago, partie: partie, position: 1,
                           donnees: { question: 'Question 1' })
        create(:evenement, date: 2.minutes.ago, partie: partie, position: 2,
                           donnees: { question: 'Question 1' })
        create(:evenement, date: 10.minutes.ago, partie: partie, position: 3,
                           donnees: { question: 'Question 2' })
        create(:evenement, date: 4.minutes.ago, partie: partie, position: 4,
                           donnees: { question: 'Question 2' })
      end

      it 'retourne les durées totales formatées pour chaque question' do
        result = service.calculer

        expect(result).to eq(
          'Question 1' => '08:00',
          'Question 2' => '06:00'
        )
      end
    end
  end
end
