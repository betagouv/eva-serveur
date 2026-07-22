require 'rails_helper'

describe Restitution::Securite::NombreDangersBienIdentifiesAvantAide1 do
  let(:metrique_nombre_dangers_bien_identifies_avant_aide1) do
    described_class.new.calcule(evenements_decores(evenements, :securite), [])
  end

  describe '#nombre_dangers_bien_identifies_avant_aide1' do
    context 'sans évenement' do
      let(:evenements) { [] }

      it { expect(metrique_nombre_dangers_bien_identifies_avant_aide1).to eq 0 }
    end

    context "avec des dangers identifiés en ayant activé l'aide" do
      let(:evenements) do
        [ build(:evenement_demarrage, date: 4.minutes.ago),
         build(:evenement_identification_danger,
               donnees: { reponse: 'oui', danger: 'danger', nom: 'avant' },
               date: 3.minutes.ago),
         build(:evenement_identification_danger,
               donnees: { reponse: 'oui', danger: 'danger', nom: 'avant' },
               date: 2.minutes.ago),
         build(:activation_aide),
         build(:evenement_identification_danger,
               donnees: { reponse: 'oui', danger: 'danger' },
               date: 2.minutes.from_now) ]
      end

      it { expect(metrique_nombre_dangers_bien_identifies_avant_aide1).to eq 2 }
    end

    context "avec des dangers identifiés aprés avoir activé l'aide" do
      let(:evenements) do
        [ build(:evenement_demarrage),
         build(:activation_aide),
         build(:evenement_identification_danger,
               donnees: { reponse: 'oui', danger: 'danger' },
               date: 2.minutes.from_now) ]
      end

      it { expect(metrique_nombre_dangers_bien_identifies_avant_aide1).to eq 0 }
    end

    context "avec un danger identifié sans avoir activé l'aide" do
      let(:evenements) do
        [ build(:evenement_demarrage),
         build(:evenement_identification_danger,
               donnees: { reponse: 'oui', danger: 'danger' },
               date: 2.minutes.from_now) ]
      end

      it { expect(metrique_nombre_dangers_bien_identifies_avant_aide1).to eq 1 }
    end
  end
end
