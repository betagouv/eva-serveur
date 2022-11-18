# frozen_string_literal: true

require 'rails_helper'

describe Restitution::Illettrisme::Synthetiseur do
  describe '#synthese' do
    let(:sujet) do
      Restitution::Illettrisme::Synthetiseur.new nil, nil
    end
    let(:algo) { double }

    before { allow(sujet).to receive(:algo).and_return(algo) }

    context 'quand la restitution détecte un illettrisme potentiel' do
      before { allow(algo).to receive(:illettrisme_potentiel?).and_return(true) }

      it { expect(sujet.synthese).to eq 'illettrisme_potentiel' }
    end

    context "quand la restitution détecte un socle cléa en cours d'aquisition" do
      before do
        allow(algo).to receive(:illettrisme_potentiel?).and_return(false)
        allow(algo).to receive(:socle_clea?).and_return(true)
      end

      it { expect(sujet.synthese).to eq 'socle_clea' }
    end

    context 'quand la restitution détecte un niveau intermédiaire' do
      before do
        allow(algo).to receive(:illettrisme_potentiel?).and_return(false)
        allow(algo).to receive(:socle_clea?).and_return(false)
        allow(algo).to receive(:aberrant?).and_return(false)
        allow(algo).to receive(:indeterminee?).and_return(false)
      end

      it { expect(sujet.synthese).to eq 'ni_ni' }
    end

    context 'quand la restitution détecte un niveau aberrant' do
      before do
        allow(algo).to receive(:illettrisme_potentiel?).and_return(false)
        allow(algo).to receive(:socle_clea?).and_return(false)
        allow(algo).to receive(:aberrant?).and_return(true)
      end

      it { expect(sujet.synthese).to eq 'aberrant' }
    end

    context "quand la restitution n'a pas de score" do
      before do
        allow(algo).to receive(:illettrisme_potentiel?).and_return(false)
        allow(algo).to receive(:socle_clea?).and_return(false)
        allow(algo).to receive(:aberrant?).and_return(false)
        allow(algo).to receive(:indeterminee?).and_return(true)
      end

      it { expect(sujet.synthese).to be_nil }
    end
  end

  describe 'pre prositionnement' do
    let(:interpreteur_pre_positionnement) { double }
    let(:subject) do
      Restitution::Illettrisme::Synthetiseur::SynthetiseurPrePositionnement
        .new interpreteur_pre_positionnement
    end

    describe '#socle_clea?' do
      context 'Socle Cléa Atteint' do
        before do
          allow(interpreteur_pre_positionnement).to receive(:interpretations_cefr)
            .and_return({ litteratie: :B1, numeratie: :Y1 })
        end

        it { expect(subject.socle_clea?).to be(true) }
      end

      context 'Socle Cléa Atteint non atteint, litteratie insufisante' do
        before do
          allow(interpreteur_pre_positionnement).to receive(:interpretations_cefr)
            .and_return({ litteratie: :A2, numeratie: :Y1 })
        end

        it { expect(subject.socle_clea?).to be(false) }
      end

      context 'Socle Cléa Atteint non atteint, numeratie insufisante' do
        before do
          allow(interpreteur_pre_positionnement).to receive(:interpretations_cefr)
            .and_return({ litteratie: :B1, numeratie: :X2 })
        end

        it { expect(subject.socle_clea?).to be(false) }
      end
    end

    describe '#illettrisme_potentiel?' do
      context "pas d'illettrisme potentiel" do
        before do
          allow(interpreteur_pre_positionnement).to receive(:interpretations_cefr)
            .and_return({ litteratie: :A1, numeratie: :X1 })
        end

        it do
          expect(subject.illettrisme_potentiel?).to be(false)
        end
      end

      context 'à cause de la litteratie' do
        before do
          allow(interpreteur_pre_positionnement).to receive(:interpretations_cefr)
            .and_return({ litteratie: :pre_A1, numeratie: :X1 })
        end

        it { expect(subject.illettrisme_potentiel?).to be(true) }
      end

      context 'à cause de la numératie' do
        before do
          allow(interpreteur_pre_positionnement).to receive(:interpretations_cefr)
            .and_return({ litteratie: :A1, numeratie: :pre_X1 })
        end

        it { expect(subject.illettrisme_potentiel?).to be(true) }
      end
    end

    describe '#indeterminee?' do
      context 'litteratie est présente' do
        before do
          allow(interpreteur_pre_positionnement).to receive(:interpretations_cefr)
            .and_return({ litteratie: :A1, numeratie: nil })
        end

        it { expect(subject.indeterminee?).to be(false) }
      end

      context 'numératie est présente' do
        before do
          allow(interpreteur_pre_positionnement).to receive(:interpretations_cefr)
            .and_return({ litteratie: nil, numeratie: :X1 })
        end

        it { expect(subject.indeterminee?).to be(false) }
      end

      context 'evaluation vide' do
        before do
          allow(interpreteur_pre_positionnement).to receive(:interpretations_cefr)
            .and_return({ litteratie: nil, numeratie: nil })
        end

        it { expect(subject.indeterminee?).to be(true) }
      end
    end
  end

  describe 'Evaluation avancées' do
    let(:interpreteur_positionnement) { double }
    let(:subject) do
      Restitution::Illettrisme::Synthetiseur.new nil, interpreteur_positionnement
    end
    describe '#synthese' do
      def synthese(profil)
        allow(interpreteur_positionnement).to receive(:synthese).and_return(
          {
            niveau_litteratie: profil
          }
        )
        subject.synthese
      end

      it { expect(synthese(:profil1)).to eq 'illettrisme_potentiel' }
      it { expect(synthese(:profil2)).to eq 'illettrisme_potentiel' }
      it { expect(synthese(:profil3)).to eq 'ni_ni' }
      it { expect(synthese(:profil4)).to eq 'socle_clea' }
      it { expect(synthese(:profil_4h_plus_plus)).to eq 'socle_clea' }
      it { expect(synthese(:profil_aberrant)).to eq 'aberrant' }
      it do
        expect(synthese(:indetermine)).to eq nil
      end
    end
  end
end
