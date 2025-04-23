# frozen_string_literal: true

require 'rails_helper'

describe Restitution::Securite::TempsBonnesQualificationsDangers do
  let(:temps_bonnes_qualifications_dangers) do
    described_class.new.calcule(evenements_decores(evenements, :securite), [])
  end

  describe '#temps_bonnes_qualifications_dangers' do
    context 'sans évenement' do
      let(:evenements) do
        [ build(:evenement_demarrage, date: Time.zone.local(2019, 10, 9, 10, 0)) ]
      end

      it { expect(temps_bonnes_qualifications_dangers).to eq({}) }
    end

    context 'avec une bonne qualification' do
      let(:evenements) do
        [ build(:evenement_demarrage, date: Time.zone.local(2019, 10, 9, 10, 0)),
         build(:evenement_ouverture_zone,
               donnees: { danger: 'casque' }, date: Time.zone.local(2019, 10, 9, 10, 1)),
         build(:evenement_qualification_danger,
               donnees: { reponse: 'bonne', danger: 'casque' },
               date: Time.zone.local(2019, 10, 9, 10, 2)) ]
      end

      it { expect(temps_bonnes_qualifications_dangers).to eq('casque' => 60) }
    end

    context 'avec deux bonnes qualifications pour des dangers différents' do
      let(:evenements) do
        [ build(:evenement_demarrage, date: Time.zone.local(2019, 10, 9, 10, 0)),
         build(:evenement_ouverture_zone,
               donnees: { danger: 'casque' }, date: Time.zone.local(2019, 10, 9, 10, 1)),
         build(:evenement_qualification_danger,
               donnees: { reponse: 'bonne', danger: 'casque' },
               date: Time.zone.local(2019, 10, 9, 10, 2)),
         build(:evenement_ouverture_zone,
               donnees: { danger: 'camion' }, date: Time.zone.local(2019, 10, 9, 10, 3)),
         build(:evenement_qualification_danger,
               donnees: { reponse: 'bonne', danger: 'camion' },
               date: Time.zone.local(2019, 10, 9, 10, 5)) ]
      end

      it do
        temps = temps_bonnes_qualifications_dangers
        expect(temps).to eq('casque' => 60, 'camion' => 120)
      end
    end

    context 'avec deux bonnes qualifications pour le même danger, on prend la première' do
      let(:evenements) do
        [ build(:evenement_demarrage, date: Time.zone.local(2019, 10, 9, 10, 0)),
         build(:evenement_ouverture_zone,
               donnees: { danger: 'casque' }, date: Time.zone.local(2019, 10, 9, 10, 1)),
         build(:evenement_qualification_danger,
               donnees: { reponse: 'bonne', danger: 'casque' },
               date: Time.zone.local(2019, 10, 9, 10, 2)),
         build(:evenement_ouverture_zone,
               donnees: { danger: 'casque' }, date: Time.zone.local(2019, 10, 9, 10, 3)),
         build(:evenement_qualification_danger,
               donnees: { reponse: 'bonne', danger: 'casque' },
               date: Time.zone.local(2019, 10, 9, 10, 5)) ]
      end

      it do
        temps = temps_bonnes_qualifications_dangers
        expect(temps).to eq('casque' => 60)
      end
    end

    context 'ignore les mauvaises qualifications' do
      let(:evenements) do
        [ build(:evenement_demarrage, date: Time.zone.local(2019, 10, 9, 10, 0)),
         build(:evenement_ouverture_zone,
               donnees: { danger: 'd1' }, date: Time.zone.local(2019, 10, 9, 10, 1)),
         build(:evenement_qualification_danger,
               donnees: { reponse: 'mauvais', danger: 'd1' },
               date: Time.zone.local(2019, 10, 9, 10, 2)) ]
      end

      it { expect(temps_bonnes_qualifications_dangers).to eq({}) }
    end

    context 'ignore les mauvaises qualifications précédant une bonne qualification' do
      let(:evenements) do
        [ build(:evenement_demarrage, date: Time.zone.local(2019, 10, 9, 10, 0)),
         build(:evenement_ouverture_zone,
               donnees: { danger: 'd1' }, date: Time.zone.local(2019, 10, 9, 10, 1)),
         build(:evenement_qualification_danger,
               donnees: { reponse: 'mauvais', danger: 'd1' },
               date: Time.zone.local(2019, 10, 9, 10, 2)),
         build(:evenement_ouverture_zone,
               donnees: { danger: 'd1' }, date: Time.zone.local(2019, 10, 9, 10, 3)),
         build(:evenement_qualification_danger,
               donnees: { reponse: 'bonne', danger: 'd1' },
               date: Time.zone.local(2019, 10, 9, 10, 5)) ]
      end

      it { expect(temps_bonnes_qualifications_dangers).to eq('d1' => 120) }
    end

    context 'ignore les mauvaises qualifications même suivant une bonne qualification' do
      let(:evenements) do
        [ build(:evenement_demarrage, date: Time.zone.local(2019, 10, 9, 10, 0)),
         build(:evenement_ouverture_zone,
               donnees: { danger: 'd1' }, date: Time.zone.local(2019, 10, 9, 10, 1)),
         build(:evenement_qualification_danger,
               donnees: { reponse: 'bonne', danger: 'd1' },
               date: Time.zone.local(2019, 10, 9, 10, 2)),
         build(:evenement_ouverture_zone,
               donnees: { danger: 'd1' }, date: Time.zone.local(2019, 10, 9, 10, 3)),
         build(:evenement_qualification_danger,
               donnees: { reponse: 'mauvais', danger: 'd1' },
               date: Time.zone.local(2019, 10, 9, 10, 5)) ]
      end

      it { expect(temps_bonnes_qualifications_dangers).to eq('d1' => 60) }
    end

    context 'ouverture sans qualification' do
      let(:evenements) do
        [ build(:evenement_demarrage, date: Time.zone.local(2019, 10, 9, 10, 0)),
         build(:evenement_ouverture_zone,
               donnees: { danger: 'danger' }, date: Time.zone.local(2019, 10, 9, 10, 1)) ]
      end

      it { expect(temps_bonnes_qualifications_dangers).to eq({}) }
    end

    context 'ignore les événements hors ouverture et qualification' do
      let(:evenements) do
        [ build(:evenement_demarrage, date: Time.zone.local(2019, 10, 9, 10, 0)),
         build(:evenement_ouverture_zone, date: Time.zone.local(2019, 10, 9, 10, 1)) ]
      end

      it { expect(temps_bonnes_qualifications_dangers).to eq({}) }
    end

    context 'ignore les zones non dangers ouvertes' do
      let(:evenements) do
        [ build(:evenement_demarrage, date: Time.zone.local(2019, 10, 9, 10, 0)),
         build(:evenement_ouverture_zone,
               donnees: {}, date: Time.zone.local(2019, 10, 9, 10, 1)),
         build(:evenement_ouverture_zone,
               donnees: { danger: 'casque' }, date: Time.zone.local(2019, 10, 9, 10, 2)),
         build(:evenement_qualification_danger,
               donnees: { reponse: 'bonne', danger: 'casque' },
               date: Time.zone.local(2019, 10, 9, 10, 3)) ]
      end

      it { expect(temps_bonnes_qualifications_dangers).to eq('casque' => 60) }
    end

    context 'plusieurs ouverture de la même zone' do
      let(:evenements) do
        [ build(:evenement_demarrage, date: Time.zone.local(2019, 10, 9, 10, 0)),
         build(:evenement_ouverture_zone,
               donnees: { danger: 'd1' }, date: Time.zone.local(2019, 10, 9, 10, 1)),
         build(:evenement_qualification_danger,
               donnees: { reponse: 'mauvais', danger: 'd1' },
               date: Time.zone.local(2019, 10, 9, 10, 2)),
         build(:evenement_ouverture_zone,
               donnees: { danger: 'd1' }, date: Time.zone.local(2019, 10, 9, 10, 3)),
         build(:evenement_qualification_danger,
               donnees: { reponse: 'bonne', danger: 'd1' },
               date: Time.zone.local(2019, 10, 9, 10, 4)) ]
      end

      it { expect(temps_bonnes_qualifications_dangers).to eq('d1' => 120) }
    end
  end
end
