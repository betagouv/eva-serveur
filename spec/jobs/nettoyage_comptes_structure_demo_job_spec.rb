# frozen_string_literal: true

require 'rails_helper'

describe ReinitialiseCompteDemoJob, type: :job do
  it "Créé la structure et le compte de démo si rien n'existe" do
    ReinitialiseCompteDemoJob.perform_now

    compte_demo = Compte.find_by(email: Eva::EMAIL_DEMO)
    expect(compte_demo).not_to be_nil
    expect(compte_demo.structure.nom).to eq(Eva::STRUCTURE_DEMO)
  end

  it 'Supprime les comptes en attentes de cette structure' do
    structure = create :structure_locale, nom: Eva::STRUCTURE_DEMO
    create :compte_admin, structure: structure
    compte_existant = create :compte_conseiller,
                             structure: structure,
                             statut_validation: :en_attente
    campagne = create :campagne, compte: compte_existant
    beneficiaire = create :beneficiaire, nom: 'nom'
    create :evaluation, nom: 'eval1', campagne: campagne, beneficiaire: beneficiaire
    create :evaluation, nom: 'eval4', campagne: campagne, beneficiaire: beneficiaire,
                        deleted_at: Time.zone.now
    create :evaluation, nom: 'eval2', campagne: campagne, beneficiaire: beneficiaire
    create :evaluation, nom: 'eval3', campagne: campagne, deleted_at: Time.zone.now
    create :campagne, libelle: 'c supprimée', compte: compte_existant, deleted_at: Time.zone.now

    NettoyageComptesStructureDemoJob.perform_now

    comptes_en_attente = Compte.where(structure: structure, statut_validation: :en_attente)
    expect(comptes_en_attente.with_deleted.count).to eq(0)
    expect(Evaluation.with_deleted.count).to eq(0)
    expect(Beneficiaire.with_deleted.count).to eq(0)
    expect(Campagne.with_deleted.count).to eq(0)

    comptes_pas_en_attente = Compte.where(structure: structure)
                                   .where.not(statut_validation: :en_attente)
    expect(comptes_pas_en_attente.with_deleted.count).to eq(1)
  end

  it 'Ne supprime le comptes nouveau.anlci@yopmail.fr' do
    structure = create :structure_locale, nom: Eva::STRUCTURE_DEMO
    create :compte_admin, structure: structure
    create :compte_conseiller, structure: structure,
                               email: Eva::EMAIL_DEMO_EN_ATTENTE,
                               statut_validation: :en_attente

    NettoyageComptesStructureDemoJob.perform_now

    comptes_en_attente = Compte.where(structure: structure, statut_validation: :en_attente)
    expect(comptes_en_attente.with_deleted.count).to eq(1)
  end
end
