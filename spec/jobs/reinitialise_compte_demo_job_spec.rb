require 'rails_helper'

describe ReinitialiseCompteDemoJob, type: :job do
  it "Créé la structure et le compte de démo si rien n'existe" do
    described_class.perform_now

    compte_demo = Compte.find_by(email: Eva::EMAIL_DEMO)
    expect(compte_demo).not_to be_nil
    expect(compte_demo.structure.nom).to eq(Eva::STRUCTURE_DEMO)
  end

  it 'Ne re-créé pas la structure si elle existe déjà' do
    structure = create :structure_locale, nom: Eva::STRUCTURE_DEMO

    described_class.perform_now

    compte_demo = Compte.find_by(email: Eva::EMAIL_DEMO)
    expect(compte_demo.structure).to eq(structure)
  end

  it "Ne re-créé pas l'admin de la structure s'il existe déjà" do
    structure = create :structure_locale, nom: Eva::STRUCTURE_DEMO
    create :compte_admin, structure: structure

    described_class.perform_now

    expect(Compte.where(role: :admin).count).to eq(1)
  end

  it "créé l'admin de la structure même s'il existe d'autres admins" do
    structure = create :structure_locale, nom: 'autre structure'
    create :compte_admin, structure: structure

    described_class.perform_now

    expect(Compte.where(role: :admin).count).to eq(2)
  end

  it 'Supprime les campagnes et les évaluations du compte de démo' do
    structure = create :structure_locale, nom: Eva::STRUCTURE_DEMO
    create :compte_admin, structure: structure
    compte_existant = create :compte_conseiller, structure: structure, email: Eva::EMAIL_DEMO
    campagne = create :campagne, compte: compte_existant
    beneficiaire = create :beneficiaire, nom: 'nom'
    create :evaluation, campagne: campagne, beneficiaire: beneficiaire
    create :evaluation, campagne: campagne, beneficiaire: beneficiaire,
                        deleted_at: Time.zone.now
    create :evaluation, campagne: campagne, beneficiaire: beneficiaire
    create :evaluation, campagne: campagne, deleted_at: Time.zone.now
    create :campagne, libelle: 'c supprimée', compte: compte_existant, deleted_at: Time.zone.now

    described_class.perform_now

    compte_demo = Compte.find_by(email: Eva::EMAIL_DEMO)
    expect(compte_demo.id).to eq(compte_existant.id)
    expect(Evaluation.with_deleted.count).to eq(0)
    expect(Beneficiaire.with_deleted.count).to eq(0)
    expect(Campagne.with_deleted.where(compte: compte_demo).count).to eq(0)
  end
end
