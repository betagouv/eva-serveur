# frozen_string_literal: true

require 'rails_helper'

describe 'nettoyage:ajoute_evenements_termines' do
  include_context 'rake'

  before do
    allow(FabriqueRestitution).to receive(:instancie).with(partie).and_return restitution
  end

  let!(:partie) { create :partie }

  context 'situation terminée' do
    let(:restitution) { double(termine?: true) }

    context 'sans événement fin' do
      let(:date_dernier_evenement) { 2.days.from_now.beginning_of_day }

      let!(:evenements) do
        [create(:evenement_piece_bien_placee, partie: partie, date: date_dernier_evenement)]
      end

      it do
        expect { subject.invoke }.to(change(Evenement, :count))

        evenement = Evenement.order(:created_at).last
        expect(evenement.nom).to eq 'finSituation'
        expect(evenement.date - date_dernier_evenement).to eq(0.001)
      end
    end

    context 'avec événement fin' do
      context "et c'est le dernier événement" do
        let!(:evenements) { [create(:evenement_fin_situation, partie: partie)] }

        it do
          expect { subject.invoke }.not_to(change(Evenement, :count))
        end
      end

      context "et ce n'est pas le dernier événement" do
        let!(:evenements) do
          [create(:evenement_fin_situation, partie: partie, date: 1.day.ago),
           create(:evenement_piece_bien_placee, partie: partie, date: 1.day.from_now)]
        end

        it do
          expect { subject.invoke }.not_to(change(Evenement, :count))
        end
      end
    end
  end

  context 'situation non terminée' do
    let(:restitution) { double(termine?: false) }

    let!(:evenements) { [] }

    it do
      expect { subject.invoke }.not_to(change(Evenement, :count))
    end
  end
end
