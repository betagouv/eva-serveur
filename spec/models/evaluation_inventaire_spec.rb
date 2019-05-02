# frozen_string_literal: true

require 'rails_helper'

describe EvaluationInventaire do
  describe EvaluationInventaire::Essai do
    it 'retourne le temps depuis le début de la situation' do
      evenements = [
        build(:evenement_ouverture_contenant, date: 2.minute.ago),
        build(:evenement_ouverture_contenant, date: 1.minute.ago)
      ]
      evaluation = described_class.new(evenements, 5.minute.ago)
      expect(evaluation.temps_total).to be_within(0.1).of(240)
    end

    describe '#nombre_erreurs' do
      it 'est à 0 en cas de réussite' do
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
        evaluation = described_class.new(evenements, 5.minute.ago)
        expect(evaluation.nombre_erreurs).to eql(0)
      end

      it 'est à 2' do
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
        evaluation = described_class.new(evenements, 5.minute.ago)
        expect(evaluation.nombre_erreurs).to eql(2)
      end

      it "est à nil lorsque le dernier événement n'est pas une saisie d'inventaire" do
        evenements = [
          build(:evenement_ouverture_contenant)
        ]
        evaluation = described_class.new(evenements, 5.minute.ago)
        expect(evaluation.nombre_erreurs).to be_nil
      end
    end
  end

  it 'session_id retourne le session_id' do
    evenements = [
      build(:evenement_demarrage, session_id: 'exemple')
    ]
    evaluation = described_class.new(evenements)
    expect(evaluation.session_id).to eql('exemple')
  end

  it 'est en reussite' do
    evenements = [
      build(:evenement_demarrage),
      build(:evenement_saisie_inventaire, :ok)
    ]
    evaluation = described_class.new(evenements)
    expect(evaluation).to be_reussite
    expect(evaluation).to be_termine
    expect(evaluation).to_not be_abandon
    expect(evaluation).to_not be_en_cours
  end

  it 'est en echec' do
    evenements = [
      build(:evenement_demarrage),
      build(:evenement_saisie_inventaire, :echec)
    ]
    evaluation = described_class.new(evenements)
    expect(evaluation).to_not be_reussite
    expect(evaluation).to_not be_abandon
    expect(evaluation).to_not be_en_cours
  end

  it 'est en abandon' do
    evenements = [
      build(:evenement_demarrage),
      build(:evenement_stop)
    ]
    evaluation = described_class.new(evenements)
    expect(evaluation).to_not be_reussite
    expect(evaluation).to be_abandon
    expect(evaluation).to_not be_en_cours
  end

  it 'est en cours' do
    evenements = [
      build(:evenement_demarrage)
    ]
    evaluation = described_class.new(evenements)
    expect(evaluation).to_not be_reussite
    expect(evaluation).to_not be_abandon
    expect(evaluation).to be_en_cours
  end

  it 'retourne le temps total' do
    evenements = [
      build(:evenement_demarrage, date: 10.minutes.ago),
      build(:evenement_saisie_inventaire, :ok, date: 4.minutes.ago)
    ]
    evaluation = described_class.new(evenements)
    expect(evaluation.temps_total).to be_within(0.1).of(360)
  end

  it "retourne le nombre d'ouverture de contenant" do
    evenements = [
      build(:evenement_ouverture_contenant),
      build(:evenement_ouverture_contenant),
      build(:evenement_ouverture_contenant)
    ]
    evaluation = described_class.new(evenements)
    expect(evaluation.nombre_ouverture_contenant).to eql(3)
  end

  it "retourne le nombre d'essai de validation" do
    evenements = [
      build(:evenement_saisie_inventaire, :echec),
      build(:evenement_saisie_inventaire, :echec),
      build(:evenement_saisie_inventaire, :echec),
      build(:evenement_saisie_inventaire, :ok)
    ]
    evaluation = described_class.new(evenements)
    expect(evaluation.nombre_essais_validation).to eql(4)
  end

  it 'retourne les essais avec le nombre de click et le temps' do
    evenements = [
      build(:evenement_demarrage, date: 10.minutes.ago),
      build(:evenement_ouverture_contenant, date: 8.minutes.ago),
      build(:evenement_ouverture_contenant, date: 8.minutes.ago),
      build(:evenement_ouverture_contenant, date: 8.minutes.ago),
      build(:evenement_saisie_inventaire, :echec, date: 7.minutes.ago),
      build(:evenement_saisie_inventaire, :ok, date: 5.minutes.ago)
    ]
    evaluation = described_class.new(evenements)
    expect(evaluation.essais.size).to eql(2)
    evaluation.essais.first.tap do |essai|
      expect(essai).to_not be_reussite
      expect(essai.nombre_ouverture_contenant).to eql(3)
      expect(essai.temps_total).to within(0.1).of(180)
    end
    evaluation.essais.last.tap do |essai|
      expect(essai).to be_reussite
      expect(essai.nombre_ouverture_contenant).to eql(0)
      expect(essai.temps_total).to within(0.1).of(300)
    end
  end
end
