# frozen_string_literal: true

require 'rails_helper'

describe Restitution::Illettrisme::Synthetiseur do
  describe '#calcule_synthese' do
    let(:algo) { double }

    context 'quand la restitution détecte un illettrisme potentiel' do
      before do
        allow(algo).to receive_messages(indetermine?: false, illettrisme_potentiel?: true)
      end

      it { expect(described_class.calcule_synthese(algo)).to eq 'illettrisme_potentiel' }
    end

    context "quand la restitution détecte un socle cléa en cours d'aquisition" do
      before do
        allow(algo).to receive_messages(indetermine?: false, illettrisme_potentiel?: false,
                                        socle_clea?: true)
      end

      it { expect(described_class.calcule_synthese(algo)).to eq 'socle_clea' }
    end

    context 'quand la restitution détecte un niveau intermédiaire' do
      before do
        allow(algo).to receive(:indetermine?).and_return(false)
        allow(algo).to receive_messages(illettrisme_potentiel?: false, socle_clea?: false,
                                        aberrant?: false)
        allow(algo).to receive(:indetermine?).and_return(false)
      end

      it { expect(described_class.calcule_synthese(algo)).to eq 'ni_ni' }
    end

    context 'quand la restitution détecte un niveau aberrant' do
      before do
        allow(algo).to receive_messages(indetermine?: false, illettrisme_potentiel?: false,
                                        socle_clea?: false, aberrant?: true)
      end

      it { expect(described_class.calcule_synthese(algo)).to eq 'aberrant' }
    end

    context "quand la restitution n'a pas de score" do
      before do
        allow(algo).to receive_messages(illettrisme_potentiel?: false, socle_clea?: false,
                                        aberrant?: false, indetermine?: true)
      end

      it { expect(described_class.calcule_synthese(algo)).to be_nil }
    end

    context 'quand la restitution détecte un niveau indetermine' do
      before do
        allow(algo).to receive(:indetermine?).and_return(true)
      end

      it { expect(described_class.calcule_synthese(algo)).to be_nil }
    end
  end

  describe 'Evaluation pre prositionnement' do
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

    describe '#indetermine?' do
      context 'litteratie est présente' do
        before do
          allow(interpreteur_pre_positionnement).to receive(:interpretations_cefr)
            .and_return({ litteratie: :A1, numeratie: nil })
        end

        it { expect(subject.indetermine?).to be(false) }
      end

      context 'numératie est présente' do
        before do
          allow(interpreteur_pre_positionnement).to receive(:interpretations_cefr)
            .and_return({ litteratie: nil, numeratie: :X1 })
        end

        it { expect(subject.indetermine?).to be(false) }
      end

      context 'evaluation vide' do
        before do
          allow(interpreteur_pre_positionnement).to receive(:interpretations_cefr)
            .and_return({ litteratie: nil, numeratie: nil })
        end

        it { expect(subject.indetermine?).to be(true) }
      end
    end
  end

  describe 'Evaluation pré-positionnement' do
    let(:interpreteur_pre_positionnement) { double }
    let(:subject) do
      described_class.new interpreteur_pre_positionnement, nil, nil
    end

    describe '#positionnement_litteratie' do
      it 'ne retourne rien' do
        expect(subject.positionnement_litteratie).to be_nil
      end
    end
  end

  describe 'Evaluation positionnement Littératie' do
    let(:interpreteur_positionnement) { double }
    let(:subject) do
      described_class.new nil, interpreteur_positionnement, nil
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
      it { expect(synthese(:indetermine)).to be_nil }
    end
  end

  describe 'Evaluation positionnement Numératie' do
    let(:interpreteur_numeratie) { double }
    let(:subject) do
      described_class.new nil, nil, interpreteur_numeratie
    end

    describe '#synthese' do
      def synthese(profil)
        allow(interpreteur_numeratie).to receive(:synthese).and_return(
          {
            profil_numeratie: profil
          }
        )
        subject.synthese
      end

      it { expect(synthese(:profil1)).to eq 'illettrisme_potentiel' }
      it { expect(synthese(:profil2)).to eq 'illettrisme_potentiel' }
      it { expect(synthese(:profil3)).to eq 'ni_ni' }
      it { expect(synthese(:profil4)).to eq 'socle_clea' }
      it { expect(synthese(:indetermine)).to be_nil }
    end
  end

  context 'quand il y a un positionnement et un pré-positionnement' do
    let(:interpreteur_positionnement) { double }
    let(:interpreteur_pre_positionnement) { double }
    let(:subject) do
      described_class.new interpreteur_pre_positionnement,
                          interpreteur_positionnement, nil
    end

    before do
      allow(interpreteur_positionnement).to receive(:synthese).and_return(
        {
          niveau_litteratie: :profil_aberrant
        }
      )
      allow(interpreteur_pre_positionnement).to receive(:interpretations_cefr).and_return(
        {
          litteratie: nil, numeratie: nil
        }
      )
    end

    describe '#synthese' do
      it 'retourne la synthèse positionnement' do
        expect(subject.synthese).to eq 'aberrant'
      end
    end

    describe '#positionnement_litteratie' do
      it 'retourne le niveau de positionnement' do
        expect(subject.positionnement_litteratie).to eq :profil_aberrant
      end
    end
  end

  context 'quand il y a un positionnement littératie et numératie' do
    let(:interpreteur_positionnement) { double }
    let(:interpreteur_numeratie) { double }
    let(:subject) do
      described_class.new nil,
                          interpreteur_positionnement,
                          interpreteur_numeratie
    end

    before do
      allow(interpreteur_positionnement).to receive(:synthese).and_return(
        {
          niveau_litteratie: :profil_aberrant
        }
      )
      allow(interpreteur_numeratie).to receive(:synthese).and_return(
        {
          profil_numeratie: :profil1
        }
      )
    end

    describe '#synthese' do
      it 'retourne la synthèse positionnement' do
        expect(subject.synthese).to eq 'aberrant'
      end
    end

    describe '#positionnement_litteratie' do
      it 'retourne le niveau de positionnement' do
        expect(subject.positionnement_litteratie).to eq :profil_aberrant
      end
    end

    describe '#positionnement_numeratie' do
      it 'retourne le niveau de positionnement de numératie' do
        expect(subject.positionnement_numeratie).to eq :profil1
      end
    end

    describe '#synthese_positionnement_numeratie' do
      it 'retourne la synthèse du niveau de positionnement de numératie' do
        expect(subject.synthese_positionnement_numeratie).to eq 'illettrisme_potentiel'
      end
    end
  end
end
