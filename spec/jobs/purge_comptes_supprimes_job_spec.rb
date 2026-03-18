require 'rails_helper'

describe PurgeComptesSupprimesJob, type: :job do
  let(:structure) { create :structure_locale, :avec_admin }

  describe '#purge_comptes_sans_evaluations' do
    it 'detruit définitivement un compte supprimé sans évaluation et ses campagnes' do
      compte = create :compte_conseiller, structure: structure, deleted_at: 2.months.ago
      create :campagne, compte: compte, deleted_at: 2.months.ago

      described_class.perform_now

      expect(Compte.with_deleted.find_by(id: compte.id)).to be_nil
      expect(Campagne.with_deleted.where(compte_id: compte.id)).to be_empty
    end

    it 'ne detruit pas un compte supprimé depuis moins d\'un mois' do
      compte = create :compte_conseiller, structure: structure, deleted_at: 1.month.ago + 1.day

      described_class.perform_now

      expect(Compte.with_deleted.find_by(id: compte.id)).not_to be_nil
    end

    it 'ne detruit pas un compte supprimé qui a des évaluations' do
      compte = create :compte_conseiller, structure: structure, deleted_at: Time.zone.now
      campagne = create :campagne, compte: compte, deleted_at: Time.zone.now
      create :evaluation, campagne: campagne, deleted_at: Time.zone.now

      described_class.perform_now

      expect(Compte.with_deleted.find_by(id: compte.id)).not_to be_nil
    end

    it "ne detruit pas un compte supprimé qui a des évaluations dans des campagnes non supprimée/
        (cas possible ne base mais qui ne devrais pas exister)" do
      compte = create :compte_conseiller, structure: structure, deleted_at: Time.zone.now
      campagne = create :campagne, compte: compte
      create :evaluation, campagne: campagne

      described_class.perform_now

      expect(Compte.with_deleted.find_by(id: compte.id)).not_to be_nil
    end

    it 'ne detruit pas les comptes actifs sans évaluation' do
      compte = create :compte_conseiller, structure: structure

      described_class.perform_now

      expect(Compte.find_by(id: compte.id)).not_to be_nil
    end

    it "detruit un compte supprimé responsable de suivi d'une évaluation et retire ce lien" do
      compte = create :compte_conseiller, structure: structure, deleted_at: 1.month.ago
      evaluation = create :evaluation, responsable_suivi: compte

      described_class.perform_now

      expect(Compte.with_deleted.find_by(id: compte.id)).to be_nil
      expect(evaluation.reload.responsable_suivi).to be_nil
    end

    it 'detruit un compte supprimé référencé par un bénéficiaire et retire ce lien' do
      compte = create :compte_conseiller, structure: structure, deleted_at: 1.month.ago
      beneficiaire = create :beneficiaire, compte: compte

      described_class.perform_now

      expect(Compte.with_deleted.find_by(id: compte.id)).to be_nil
      expect(beneficiaire.reload.compte).to be_nil
    end

    it 'detruit un compte supprimé référencé par un bénéficiaire supprimé et retire ce lien' do
      compte = create :compte_conseiller, structure: structure, deleted_at: 1.month.ago
      beneficiaire = create :beneficiaire, compte: compte, deleted_at: 1.month.ago

      described_class.perform_now

      expect(Compte.with_deleted.find_by(id: compte.id)).to be_nil
      expect(beneficiaire.reload.compte).to be_nil
    end

    it "detruit un compte supprimé responsable de suivi d'une évaluation supprimé et retire ce lien" do
      compte = create :compte_conseiller, structure: structure, deleted_at: 1.month.ago
      evaluation = create :evaluation, responsable_suivi: compte, deleted_at: 1.month.ago

      described_class.perform_now

      expect(Compte.with_deleted.find_by(id: compte.id)).to be_nil
      expect(evaluation.reload.responsable_suivi).to be_nil
    end
  end

  describe '#anonymise_comptes_avec_evaluations' do
    it 'anonymise les comptes supprimés qui ont des évaluations' do
      compte = create :compte_conseiller, structure: structure, deleted_at: 1.month.ago
      campagne = create :campagne, compte: compte, deleted_at: Time.zone.now
      create :evaluation, campagne: campagne

      anonymisation = instance_double(Anonymisation::Compte)
      allow(Anonymisation::Compte).to receive(:new).with(compte).and_return(anonymisation)
      expect(anonymisation).to receive(:anonymise)

      described_class.perform_now
    end

    it "n'anonymise pas un compte supprimé depuis moins d'un mois" do
      compte = create :compte_conseiller, structure: structure, deleted_at: 1.month.ago + 1.day
      campagne = create :campagne, compte: compte, deleted_at: 1.month.ago + 1.day
      create :evaluation, campagne: campagne

      expect(Anonymisation::Compte).not_to receive(:new)

      described_class.perform_now
    end
  end
end
