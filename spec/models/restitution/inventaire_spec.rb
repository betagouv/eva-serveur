# frozen_string_literal: true

require 'rails_helper'

describe Restitution::Inventaire do
  let(:campagne) { build :campagne }

  describe Restitution::Inventaire::Essai do
    it 'retourne le temps depuis le début de la situation' do
      evenements = [
        build(:evenement_ouverture_contenant, date: 2.minutes.ago),
        build(:evenement_ouverture_contenant, date: 1.minute.ago)
      ]
      restitution = described_class.new(campagne, evenements, 5.minutes.ago)
      expect(restitution.temps_total).to be_within(0.1).of(240)
    end

    describe 'nombre_erreurs, nombre_de_non_remplissage, nombre_erreurs_sauf_de_non_remplissage' do
      it 'en cas de réussite' do
        evenements = [
          build(:evenement_saisie_inventaire, :ok, donnees: {
                  reussite: true,
                  reponses: {
                    '1': { quantite: 2, reussite: true },
                    '2': { quantite: 1, reussite: true },
                    '3': { quantite: 4, reussite: true }
                  }
                })
        ]
        restitution = described_class.new(campagne, evenements, 5.minutes.ago)
        expect(restitution.nombre_erreurs).to be(0)
        expect(restitution.nombre_de_non_remplissage).to be(0)
        expect(restitution.nombre_erreurs_sauf_de_non_remplissage).to be(0)
      end

      it 'avec 2 erreurs' do
        evenements = [
          build(:evenement_saisie_inventaire, :echec, donnees: {
                  reussite: false,
                  reponses: {
                    '1': { quantite: 2, reussite: true },
                    '2': { quantite: 1, reussite: false },
                    '3': { quantite: 4, reussite: false }
                  }
                })
        ]
        restitution = described_class.new(campagne, evenements, 5.minutes.ago)
        expect(restitution.nombre_erreurs).to be(2)
        expect(restitution.nombre_de_non_remplissage).to be(0)
        expect(restitution.nombre_erreurs_sauf_de_non_remplissage).to be(2)
      end

      it "avec le dernier événement qui n'est pas une saisie d'inventaire" do
        evenements = [
          build(:evenement_ouverture_contenant)
        ]
        restitution = described_class.new(campagne, evenements, 5.minutes.ago)
        expect(restitution.nombre_erreurs).to be_nil
        expect(restitution.nombre_de_non_remplissage).to be_nil
        expect(restitution.nombre_erreurs_sauf_de_non_remplissage).to be_nil
      end

      it 'avec un non remplissage' do
        evenements = [
          build(:evenement_saisie_inventaire, :ok, donnees: {
                  reussite: true,
                  reponses: {
                    '1': { quantite: '', reussite: false },
                    '2': { quantite: 1, reussite: true },
                    '3': { quantite: 4, reussite: true }
                  }
                })
        ]
        restitution = described_class.new(campagne, evenements, 5.minutes.ago)
        expect(restitution.nombre_erreurs).to be(1)
        expect(restitution.nombre_de_non_remplissage).to be(1)
        expect(restitution.nombre_erreurs_sauf_de_non_remplissage).to be(0)
      end
    end
  end

  it 'est en reussite' do
    evenements = [
      build(:evenement_demarrage),
      build(:evenement_saisie_inventaire, :ok),
      build(:evenement_fin_situation)
    ]
    restitution = described_class.new(campagne, evenements)
    expect(restitution).to be_reussite
    expect(restitution).to be_termine
    expect(restitution).not_to be_abandon
    expect(restitution).not_to be_en_cours
  end

  it 'est terminé' do
    evenements = [
      build(:evenement_demarrage),
      build(:evenement_fin_situation)
    ]
    restitution = described_class.new(campagne, evenements)
    expect(restitution).to be_termine
    expect(restitution).to be_reussite
  end

  it 'est en abandon' do
    evenements = [
      build(:evenement_demarrage),
      build(:evenement_abandon)
    ]
    restitution = described_class.new(campagne, evenements)
    expect(restitution).not_to be_termine
    expect(restitution).to be_abandon
    expect(restitution).not_to be_en_cours
  end

  it 'est en cours' do
    evenements = [
      build(:evenement_demarrage)
    ]
    restitution = described_class.new(campagne, evenements)
    expect(restitution).not_to be_termine
    expect(restitution).not_to be_abandon
    expect(restitution).to be_en_cours
  end

  it 'retourne le temps total' do
    evenements = [
      build(:evenement_demarrage, date: 10.minutes.ago),
      build(:evenement_saisie_inventaire, :ok, date: 4.minutes.ago)
    ]
    restitution = described_class.new(campagne, evenements)
    expect(restitution.temps_total).to be_within(0.1).of(360)
  end

  it "retourne le nombre d'ouverture de contenant" do
    evenements = [
      build(:evenement_ouverture_contenant),
      build(:evenement_ouverture_contenant),
      build(:evenement_ouverture_contenant)
    ]
    restitution = described_class.new(campagne, evenements)
    expect(restitution.nombre_ouverture_contenant).to be(3)
  end

  it "retourne le nombre d'essai de validation" do
    evenements = [
      build(:evenement_saisie_inventaire, :echec),
      build(:evenement_saisie_inventaire, :echec),
      build(:evenement_saisie_inventaire, :echec),
      build(:evenement_saisie_inventaire, :ok)
    ]
    restitution = described_class.new(campagne, evenements)
    expect(restitution.nombre_essais_validation).to be(4)
  end

  describe '#essais_verifies' do
    it "Quand seul l'évenement de fin a été enregistré" do
      evenements = [
        build(:evenement_fin_situation)
      ]
      restitution = described_class.new(campagne, evenements)
      expect(restitution.essais_verifies).to eq([])
    end

    it 'retourne les essais verifiés avec le nombre de click et le temps' do
      evenements = [
        build(:evenement_demarrage, date: 10.minutes.ago),
        build(:evenement_ouverture_contenant, date: 8.minutes.ago),
        build(:evenement_ouverture_contenant, date: 8.minutes.ago),
        build(:evenement_ouverture_contenant, date: 8.minutes.ago),
        build(:evenement_saisie_inventaire, :echec, date: 7.minutes.ago),
        build(:evenement_saisie_inventaire, :ok, date: 5.minutes.ago),
        build(:evenement_fin_situation)
      ]
      restitution = described_class.new(campagne, evenements)
      expect(restitution.essais_verifies.size).to be(2)
      restitution.essais_verifies.first.tap do |essai|
        expect(essai).not_to be_reussite
        expect(essai).not_to be_abandon
        expect(essai).to be_verifie
        expect(essai.nombre_ouverture_contenant).to be(3)
        expect(essai.temps_total).to within(0.2).of(180)
      end
      restitution.essais_verifies.last.tap do |essai|
        expect(essai).to be_reussite
        expect(essai).to be_verifie
        expect(essai.nombre_ouverture_contenant).to be(0)
        expect(essai.temps_total).to within(0.2).of(300)
      end
    end

    it 'retourne seulement les essais vérifiés' do
      evenements = [
        build(:evenement_demarrage, date: 10.minutes.ago),
        build(:evenement_ouverture_contenant, date: 8.minutes.ago),
        build(:evenement_saisie_inventaire, :echec, date: 7.minutes.ago),
        build(:evenement_ouverture_contenant, date: 6.minutes.ago),
        build(:evenement_saisie_inventaire, :echec, date: 5.minutes.ago),
        build(:evenement_ouverture_contenant, date: 4.minutes.ago)
      ]
      restitution = described_class.new(campagne, evenements)
      expect(restitution.essais_verifies.size).to be(2)
    end
  end

  describe '#essais' do
    it 'retourne tout les essais même non vérifié' do
      evenements = [
        build(:evenement_demarrage, date: 10.minutes.ago),
        build(:evenement_ouverture_contenant, date: 8.minutes.ago),
        build(:evenement_saisie_inventaire, :echec, date: 7.minutes.ago),
        build(:evenement_ouverture_contenant, date: 6.minutes.ago),
        build(:evenement_saisie_inventaire, :echec, date: 5.minutes.ago),
        build(:evenement_ouverture_contenant, date: 4.minutes.ago)
      ]
      restitution = described_class.new(campagne, evenements)
      expect(restitution.essais.size).to be(3)
      expect(restitution.essais.last).not_to be_verifie
    end

    it "ne retourne pas d'essai pour l'événement de fin situation" do
      evenements = [
        build(:evenement_demarrage, date: 10.minutes.ago),
        build(:evenement_ouverture_contenant, date: 8.minutes.ago),
        build(:evenement_saisie_inventaire, :ok, date: 7.minutes.ago),
        build(:evenement_fin_situation)
      ]
      restitution = described_class.new(campagne, evenements)
      expect(restitution.essais.size).to be(1)
    end
  end

  describe '#competences' do
    it 'retourne les compétences évaluées' do
      evenements = [
        build(:evenement_demarrage)
      ]
      restitution = described_class.new(campagne, evenements)
      expect(restitution.competences.keys).to eql([Competence::PERSEVERANCE,
                                                   Competence::COMPREHENSION_CONSIGNE,
                                                   Competence::RAPIDITE,
                                                   Competence::VIGILANCE_CONTROLE,
                                                   Competence::ORGANISATION_METHODE])
    end
  end

  describe '#version?' do
    context "si il y a un numéro de version dans l'évènement démarrage" do
      before do
        evenements = [
          build(:evenement_demarrage, donnees: { version: '2' })
        ]
        @restitution = described_class.new(campagne, evenements)
      end

      it { expect(@restitution.version?('2')).to be true }
      it { expect(@restitution.version?('1')).to be false }
    end

    context "si il n'y a pas de numéro de version" do
      before do
        evenements = [
          build(:evenement_demarrage, donnees: {})
        ]
        @restitution = described_class.new(campagne, evenements)
      end

      it { expect(@restitution.version?(2)).to be false }
    end

    context "si il n'y a pas d'événement démarrage" do
      before do
        evenements = []
        @restitution = described_class.new(campagne, evenements)
      end

      it { expect(@restitution.version?(2)).to be false }
    end
  end
end
