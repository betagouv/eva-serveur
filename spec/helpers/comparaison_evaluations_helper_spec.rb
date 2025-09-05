require 'rails_helper'

describe ComparaisonEvaluationsHelper, type: :helper do
  describe '#sous_competences_litteratie' do
    context 'quand la restitution litteratie est nil' do
      it 'retourne un Hash vide' do
        comparaison = double("comparaison")
        allow(helper).to receive(:restitution_litteratie).and_return(nil)
        expect(helper.sous_competences_litteratie(comparaison, 0)).to eq({})
      end
    end
  end
end
