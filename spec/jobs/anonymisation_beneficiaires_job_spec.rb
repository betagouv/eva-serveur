# frozen_string_literal: true

require 'rails_helper'

describe AnonymisationBeneficiairesJob, type: :job do
  it "n'anonymise pas les bénéficiaires qui ont au moins une évaluations recente" do
    date_anonymisation = Time.zone.local(2025, 1, 2, 12, 0, 0)
    Timecop.freeze(date_anonymisation) do
      beneficiaire = create :beneficiaire, nom: 'nom'
      ancienne_evaluation = create :evaluation, created_at: Date.new(2020, 1, 1),
                                                beneficiaire: beneficiaire
      evaluation_recente = create :evaluation, created_at: Date.new(2020, 1, 3),
                                               beneficiaire: beneficiaire

      described_class.perform_now

      beneficiaire.reload
      ancienne_evaluation.reload
      evaluation_recente.reload

      expect(beneficiaire.anonymise_le).to be_nil
      expect(ancienne_evaluation.anonymise_le).to be_nil
      expect(evaluation_recente.anonymise_le).to be_nil
    end
  end

  it "anonymise les bénéficiaires qui n'ont que des évaluations ancienne" do
    date_anonymisation = Time.zone.local(2025, 1, 2, 12, 0, 0)
    Timecop.freeze(date_anonymisation) do
      expect(FFaker::NameFR).to receive(:name).and_return('nom généré')
      beneficiaire = create :beneficiaire, nom: 'nom'
      ancienne_evaluation = create :evaluation, created_at: Date.new(2020, 1, 1),
                                                beneficiaire: beneficiaire
      autre_evaluation_ancienne = create :evaluation, created_at: Date.new(2019, 1, 1),
                                                      beneficiaire: beneficiaire

      described_class.perform_now

      beneficiaire.reload
      ancienne_evaluation.reload
      autre_evaluation_ancienne.reload

      expect(beneficiaire.anonymise_le).to eq date_anonymisation
      expect(ancienne_evaluation.anonymise_le).to eq date_anonymisation
      expect(autre_evaluation_ancienne.anonymise_le).to eq date_anonymisation

      expect(beneficiaire.nom).to eq 'nom généré'
      expect(ancienne_evaluation.nom).to eq 'nom généré'
      expect(autre_evaluation_ancienne.nom).to eq 'nom généré'
    end
  end

  it "n'anonymise pas les bénéficiaires déjà annonymisé" do
    date_anonymisation = Time.zone.local(2025, 1, 2, 12, 0, 0)
    Timecop.freeze(date_anonymisation) do
      annonymisiation_existante = Time.zone.local(2024, 1, 1, 0, 0, 0)
      beneficiaire = create :beneficiaire, nom: 'nom', anonymise_le: annonymisiation_existante
      ancienne_evaluation = create :evaluation, created_at: Date.new(2019, 1, 1),
                                                beneficiaire: beneficiaire,
                                                anonymise_le: annonymisiation_existante
      evaluation_recente = create :evaluation, created_at: Date.new(2019, 1, 1),
                                               beneficiaire: beneficiaire,
                                               anonymise_le: annonymisiation_existante

      described_class.perform_now

      beneficiaire.reload
      ancienne_evaluation.reload
      evaluation_recente.reload

      expect(beneficiaire.anonymise_le).to eq annonymisiation_existante
      expect(ancienne_evaluation.anonymise_le).to eq annonymisiation_existante
      expect(evaluation_recente.anonymise_le).to eq annonymisiation_existante
    end
  end
end
