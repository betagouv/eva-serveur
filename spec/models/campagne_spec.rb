# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Campagne, type: :model do
  it { should validate_presence_of :libelle }
  it { should validate_uniqueness_of :code }
  it { should belong_to(:questionnaire).optional }

  describe 'validation du code' do
    context 'garde le code initial' do
      let(:campagne) { Campagne.new code: 'mon code' }
      before { campagne.valid? }
      it { expect(campagne.code).to eq 'mon code' }
    end

    context 'sans code initial génère un code unique' do
      let(:campagne) { Campagne.new code: nil }
      before do
        allow(SecureRandom).to receive(:hex).with(3).and_return('abcde', '12345')
        allow(Campagne).to receive(:where).with(code: 'abcde').and_return(double(none?: false))
        allow(Campagne).to receive(:where).with(code: '12345').and_return(double(none?: true))
        campagne.valid?
      end
      it { expect(campagne.code).to eq '12345' }
    end

    context 'initialise la campagne' do
      let(:compte) { Compte.new email: 'accompagnant@email.com', password: 'secret' }
      before do
        Campagne::SITUATIONS_PAR_DEFAUT.each do |nom_situation|
          situation = Situation.new libelle: nom_situation, nom_technique: nom_situation
          allow(Situation).to receive(:find_by).with(nom_technique: nom_situation)
                                               .and_return(situation)
        end
      end

      context "n'ajoute aucune situation quand ce n'est pas demandé" do
        let(:campagne) do
          Campagne.new libelle: 'ma campagne',
                       code: 'moncode',
                       compte: compte,
                       initialise_situations: false
        end
        before { expect(campagne.valid?).to be(true) }
        it do
          campagne.save
          expect(campagne.situations.count).to eq 0
        end
      end

      context "ajoute les situations par defaut quand c'est demandé" do
        let(:campagne) do
          Campagne.new libelle: 'ma campagne',
                       code: 'moncode',
                       compte: compte,
                       initialise_situations: true
        end
        before { expect(campagne.valid?).to be(true) }
        it do
          campagne.save
          expect(campagne.situations.count).to eq Campagne::SITUATIONS_PAR_DEFAUT.length
        end
      end
    end
  end
end
