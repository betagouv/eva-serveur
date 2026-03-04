require 'rails_helper'

describe PurgeComptesSupprimesJob, type: :job do
  let(:structure) { create :structure_locale, :avec_admin }

  it 'supprime définitivement un compte supprimé sans évaluation et ses campagnes' do
    compte = create :compte_conseiller, structure: structure, deleted_at: Time.zone.now
    create :campagne, compte: compte, deleted_at: Time.zone.now

    described_class.perform_now

    expect(Compte.with_deleted.find_by(id: compte.id)).to be_nil
    expect(Campagne.with_deleted.where(compte_id: compte.id)).to be_empty
  end

  it 'ne supprime pas un compte supprimé qui a des évaluations' do
    compte = create :compte_conseiller, structure: structure, deleted_at: Time.zone.now
    campagne = create :campagne, compte: compte, deleted_at: Time.zone.now
    create :evaluation, campagne: campagne

    described_class.perform_now

    expect(Compte.with_deleted.find_by(id: compte.id)).not_to be_nil
  end

  it 'ne supprime pas un compte supprimé qui a des évaluations supprimées' do
    compte = create :compte_conseiller, structure: structure, deleted_at: Time.zone.now
    campagne = create :campagne, compte: compte, deleted_at: Time.zone.now
    create :evaluation, campagne: campagne, deleted_at: Time.zone.now

    described_class.perform_now

    expect(Compte.with_deleted.find_by(id: compte.id)).not_to be_nil
  end

  it 'ne supprime pas les comptes actifs sans évaluation' do
    compte = create :compte_conseiller, structure: structure

    described_class.perform_now

    expect(Compte.find_by(id: compte.id)).not_to be_nil
  end
end
