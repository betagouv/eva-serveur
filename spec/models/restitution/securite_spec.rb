# frozen_string_literal: true

require 'rails_helper'

describe Restitution::Securite do
  let(:campagne) { Campagne.new }
  let(:restitution) { Restitution::Securite.new campagne, evenements }

  describe '#termine?' do
    context 'aucun danger qualifié' do
      let(:evenements) { [] }
      it { expect(restitution).to_not be_termine }
    end

    context 'tous les dangers qualifiés' do
      let(:evenements) do
        [
          build(:evenement_demarrage),
          Array.new(Restitution::Securite::DANGERS_TOTAL) do |index|
            build(:evenement_qualification_danger, donnees: { danger: "danger-#{index}" })
          end
        ].flatten
      end
      it { expect(restitution).to be_termine }
    end

    context 'ignore les requalifications de danger' do
      let(:evenements) do
        [
          build(:evenement_demarrage),
          Array.new(Restitution::Securite::DANGERS_TOTAL) do
            build(:evenement_qualification_danger, donnees: { danger: 'danger' })
          end
        ].flatten
      end
      it { expect(restitution).to_not be_termine }
    end
  end

  describe '#nombre_bien_qualifies' do
    context 'sans évenement' do
      let(:evenements) { [] }
      it { expect(restitution.nombre_bien_qualifies).to eq 0 }
    end

    context 'avec bonne qualification' do
      let(:evenements) do
        [build(:evenement_demarrage),
         build(:evenement_qualification_danger, :bon)]
      end
      it { expect(restitution.nombre_bien_qualifies).to eq 1 }
    end

    context 'ignore les mauvaises qualifications' do
      let(:evenements) do
        [build(:evenement_demarrage),
         build(:evenement_qualification_danger, :mauvais)]
      end
      it { expect(restitution.nombre_bien_qualifies).to eq 0 }
    end

    context 'prend en compte la requalification' do
      let(:evenements) do
        [build(:evenement_demarrage),
         build(:evenement_qualification_danger,
               donnees: { reponse: 'mauvais', danger: 'danger' }, created_at: 1.minute.ago),
         build(:evenement_qualification_danger,
               donnees: { reponse: 'bonne', danger: 'danger' }, created_at: 2.minutes.ago)]
      end
      it { expect(restitution.nombre_bien_qualifies).to eq 0 }
    end
  end

  describe '#nombre_dangers_identifies' do
    context 'sans évenement' do
      let(:evenements) { [] }
      it { expect(restitution.nombre_dangers_identifies).to eq 0 }
    end

    context 'avec bonne identification' do
      let(:evenements) do
        [build(:evenement_demarrage),
         build(:evenement_identification_danger, donnees: { reponse: 'oui', danger: 'danger' })]
      end
      it { expect(restitution.nombre_dangers_identifies).to eq 1 }
    end

    context 'ignore les réponses négatives' do
      let(:evenements) do
        [build(:evenement_demarrage),
         build(:evenement_identification_danger, donnees: { reponse: 'non' })]
      end
      it { expect(restitution.nombre_dangers_identifies).to eq 0 }
    end

    context 'ignore les identifications de zone sans danger' do
      let(:evenements) do
        [build(:evenement_demarrage),
         build(:evenement_identification_danger, donnees: { reponse: 'oui' })]
      end
      it { expect(restitution.nombre_dangers_identifies).to eq 0 }
    end
  end

  describe '#nombre_retours_deja_qualifies' do
    context 'sans évenement' do
      let(:evenements) { [] }
      it { expect(restitution.nombre_retours_deja_qualifies).to eq 0 }
    end

    context 'deux qualifications du même danger' do
      let(:evenements) do
        [build(:evenement_demarrage),
         build(:evenement_qualification_danger,
               donnees: { reponse: 'mauvais', danger: 'danger' }),
         build(:evenement_qualification_danger,
               donnees: { reponse: 'bonne', danger: 'danger' })]
      end
      it { expect(restitution.nombre_retours_deja_qualifies).to eq 1 }
    end
  end

  describe '#nombre_dangers_identifies_avant_aide_1' do
    context 'sans évenement' do
      let(:evenements) { [] }
      it { expect(restitution.nombre_dangers_identifies_avant_aide_1).to eq 0 }
    end

    context "avec des dangers identifiés en ayant activé l'aide" do
      let(:evenements) do
        [build(:evenement_demarrage, date: 4.minutes.ago),
         build(:evenement_identification_danger,
               donnees: { reponse: 'oui', danger: 'danger', nom: 'avant' },
               date: 3.minutes.ago),
         build(:evenement_identification_danger,
               donnees: { reponse: 'oui', danger: 'danger', nom: 'avant' },
               date: 2.minutes.ago),
         build(:activation_aide),
         build(:evenement_identification_danger,
               donnees: { reponse: 'oui', danger: 'danger' },
               date: 2.minutes.from_now)]
      end
      it { expect(restitution.nombre_dangers_identifies_avant_aide_1).to eq 2 }
    end

    context "avec des dangers identifiés aprés avoir activé l'aide" do
      let(:evenements) do
        [build(:evenement_demarrage),
         build(:activation_aide),
         build(:evenement_identification_danger,
               donnees: { reponse: 'oui', danger: 'danger' },
               date: 2.minutes.from_now)]
      end
      it { expect(restitution.nombre_dangers_identifies_avant_aide_1).to eq 0 }
    end

    context "avec un danger identifié sans avoir activé l'aide" do
      let(:evenements) do
        [build(:evenement_demarrage),
         build(:evenement_identification_danger,
               donnees: { reponse: 'oui', danger: 'danger' },
               date: 2.minutes.from_now)]
      end
      it { expect(restitution.nombre_dangers_identifies_avant_aide_1).to eq 1 }
    end
  end

  describe '#temps_ouvertures_zones_dangers' do
    context 'sans zone danger ouverte' do
      let(:evenements) { [] }
      it { expect(restitution.temps_ouvertures_zones_dangers).to eq [] }
    end

    context 'une zone danger ouverte' do
      let(:evenements) do
        [build(:evenement_demarrage, date: Time.local(2019, 10, 9, 10, 0)),
         build(:evenement_ouverture_zone,
               donnees: { danger: 'danger' }, date: Time.local(2019, 10, 9, 10, 1))]
      end
      it { expect(restitution.temps_ouvertures_zones_dangers).to eq [60] }
    end

    context 'deux zone danger ouverts' do
      let(:evenements) do
        [build(:evenement_demarrage, date: Time.local(2019, 10, 9, 10, 0)),
         build(:evenement_ouverture_zone,
               donnees: { danger: 'danger' }, date: Time.local(2019, 10, 9, 10, 1)),
         build(:evenement_qualification_danger, date: Time.local(2019, 10, 9, 10, 2)),
         build(:evenement_ouverture_zone,
               donnees: { danger: 'd2' }, date: Time.local(2019, 10, 9, 10, 4))]
      end
      it { expect(restitution.temps_ouvertures_zones_dangers).to eq [60, 120] }
    end

    context 'ignore les zones non dangers ouverts' do
      let(:evenements) do
        [build(:evenement_demarrage, date: Time.local(2019, 10, 9, 10, 0)),
         build(:evenement_ouverture_zone,
               donnees: {}, date: Time.local(2019, 10, 9, 10, 1)),
         build(:evenement_ouverture_zone,
               donnees: { danger: 'danger' }, date: Time.local(2019, 10, 9, 10, 3))]
      end
      it { expect(restitution.temps_ouvertures_zones_dangers).to eq [180] }
    end

    context 'quand on ne finit pas par une identification' do
      let(:evenements) do
        [build(:evenement_demarrage, date: Time.local(2019, 10, 9, 10, 0)),
         build(:evenement_ouverture_zone,
               donnees: { danger: 'danger' }, date: Time.local(2019, 10, 9, 10, 1)),
         build(:evenement_qualification_danger, date: Time.local(2019, 10, 9, 10, 2))]
      end
      it { expect(restitution.temps_ouvertures_zones_dangers).to eq [60] }
    end

    context 'ignore les requalifications' do
      let(:evenements) do
        [build(:evenement_demarrage, date: Time.local(2019, 10, 9, 10, 0)),
         build(:evenement_ouverture_zone,
               donnees: { danger: 'danger' }, date: Time.local(2019, 10, 9, 10, 1)),
         build(:evenement_qualification_danger, date: Time.local(2019, 10, 9, 10, 2)),
         build(:evenement_qualification_danger, date: Time.local(2019, 10, 9, 10, 3)),
         build(:evenement_ouverture_zone,
               donnees: { danger: 'd2' }, date: Time.local(2019, 10, 9, 10, 5))]
      end
      it { expect(restitution.temps_ouvertures_zones_dangers).to eq [60, 180] }
    end
  end

  describe '#attention_visuo_spatiale' do
    context 'sans évenement: indéterminé' do
      let(:evenements) { [] }
      it { expect(restitution.attention_visuo_spatiale).to eq Competence::NIVEAU_INDETERMINE }
    end

    context "avec identification du danger sans avoir activé l'aide" do
      let(:evenements) do
        [build(:evenement_demarrage),
         build(:evenement_identification_danger,
               donnees: { reponse: 'oui', danger: Restitution::Securite::DANGER_VISUO_SPATIAL })]
      end

      it { expect(restitution.attention_visuo_spatiale).to eq Competence::APTE }
    end

    context "avec identification du danger après avoir activé l'aide" do
      let(:evenements) do
        [build(:evenement_demarrage, date: 3.minute.ago),
         build(:activation_aide, date: 2.minutes.ago),
         build(:evenement_identification_danger,
               donnees: { reponse: 'oui', danger: Restitution::Securite::DANGER_VISUO_SPATIAL },
               date: 1.minute.ago)]
      end
      it { expect(restitution.attention_visuo_spatiale).to eq Competence::APTE_AVEC_AIDE }
    end

    context "avec identification du danger avant avoir activé l'aide" do
      let(:evenements) do
        [build(:evenement_demarrage, date: 3.minute.ago),
         build(:evenement_identification_danger,
               donnees: { reponse: 'oui', danger: Restitution::Securite::DANGER_VISUO_SPATIAL },
               date: 2.minute.ago),
         build(:activation_aide, date: 1.minutes.ago)]
      end
      it { expect(restitution.attention_visuo_spatiale).to eq Competence::APTE }
    end
  end

  describe '#nombre_reouverture_zone_sans_danger' do
    context 'sans réouverture' do
      let(:evenements) do
        [build(:evenement_demarrage),
         build(:evenement_ouverture_zone, donnees: { zone: 'zone1' })]
      end

      it { expect(restitution.nombre_reouverture_zone_sans_danger).to eq 0 }
    end

    context 'avec une réouverture' do
      let(:evenements) do
        [build(:evenement_demarrage),
         build(:evenement_ouverture_zone, donnees: { zone: 'zone1' }),
         build(:evenement_ouverture_zone, donnees: { zone: 'zone2' }),
         build(:evenement_ouverture_zone, donnees: { zone: 'zone1' })]
      end

      it { expect(restitution.nombre_reouverture_zone_sans_danger).to eq 1 }
    end

    context "avec une autre réouverture d'une zone avec danger" do
      let(:evenements) do
        [build(:evenement_demarrage),
         build(:evenement_ouverture_zone, donnees: { zone: 'zone1' }),
         build(:evenement_ouverture_zone, donnees: { zone: 'zone2' }),
         build(:evenement_ouverture_zone, donnees: { zone: 'zone3', danger: 'danger1' }),
         build(:evenement_ouverture_zone, donnees: { zone: 'zone3', danger: 'danger1' }),
         build(:evenement_ouverture_zone, donnees: { zone: 'zone1' })]
      end

      it { expect(restitution.nombre_reouverture_zone_sans_danger).to eq 1 }
    end
  end

  describe '#temps_entrainement' do
    context "lorsqu'il est terminé" do
      let(:evenements) do
        [build(:evenement_demarrage_entrainement, date: Time.local(2019, 10, 9, 10, 2)),
         build(:evenement_identification_danger,
               donnees: { reponse: 'oui', danger: 'danger' }, date: Time.local(2019, 10, 9, 10, 3)),
         build(:evenement_qualification_danger, date: Time.local(2019, 10, 9, 10, 7))]
      end

      it { expect(restitution.temps_entrainement).to eq 5.minutes }
    end

    context "lorsqu'il n'est pas terminé" do
      let(:evenements) do
        [build(:evenement_demarrage_entrainement, date: Time.local(2019, 10, 9, 10, 2)),
         build(:evenement_identification_danger,
               donnees: { reponse: 'oui', danger: 'danger' },
               date: Time.local(2019, 10, 9, 10, 4))]
      end

      it { expect(restitution.temps_entrainement).to eq 2.minutes }
    end

    context 'ne prend pas en compte le temps de la situation' do
      let(:evenements) do
        [build(:evenement_demarrage_entrainement, date: Time.local(2019, 10, 9, 10, 2)),
         build(:evenement_identification_danger,
               donnees: { reponse: 'oui', danger: 'danger' },
               date: Time.local(2019, 10, 9, 10, 4)),
         build(:evenement_qualification_danger, date: Time.local(2019, 10, 9, 10, 4)),
         build(:evenement_demarrage, date: Time.local(2019, 10, 9, 10, 6)),
         build(:evenement_identification_danger)]
      end

      it { expect(restitution.temps_entrainement).to eq 2.minutes }
    end
  end
end
