# frozen_string_literal: true

require 'rails_helper'

describe Compte do
  it do
    expect(subject).to define_enum_for(:role)
      .with_values(
        superadmin: 'superadmin',
        charge_mission_regionale: 'charge_mission_regionale',
        admin: 'admin',
        conseiller: 'conseiller',
        compte_generique: 'compte_generique'
      )
      .backed_by_column_of_type(:string)
  end

  it { is_expected.to belong_to(:structure).optional }
  it { is_expected.to validate_presence_of :statut_validation }
  it { is_expected.to validate_presence_of :nom }
  it { is_expected.to validate_presence_of :prenom }

  context 'quand un compte a été soft-delete' do
    let(:compte) { build :compte, email: 'mon-email-supprime@example.com' }
    before do
      autre_compte = create :compte, email: 'mon-email-supprime@example.com'
      autre_compte.destroy
    end

    it "Peut ré-utiliser l'adresse email d'un compte effacé" do
      expect(compte.save).to eq true
    end
  end

  it do
    expect(subject).to define_enum_for(:statut_validation)
      .with_values(%i[en_attente acceptee refusee])
      .with_prefix(:validation)
  end

  it { expect(described_class.new(prenom: 'Pepa', nom: 'Pig').display_name).to eql('Pepa Pig') }
  it { expect(described_class.new.display_name).to eql('') }

  it do
    expect(described_class.new(email: 'pepa@france5.fr').display_name)
      .to eql('pepa@france5.fr')
  end

  it do
    expect(described_class.new(nom: 'Pig', email: 'pepa@france5.fr').display_name)
      .to eql('Pig')
  end

  it do
    expect(described_class.new(prenom: 'Pepa', nom: 'Pig', email: 'pepa@france5.fr').display_name)
      .to eql('Pepa Pig')
  end

  describe "validation DNS de l'email" do
    let(:compte) { Compte.new email: 'email@example.com' }

    before do
      allow(compte).to receive(:email_changed?).and_return(true)
      allow(Truemail).to receive(:valid?).and_return(true)
    end

    context "quand l'email est valide" do
      before { compte.valid? }

      it { expect(compte.errors[:email]).to be_blank }
    end

    context "quand l'email est invalide" do
      before { allow(Truemail).to receive(:valid?).with('email@example.com').and_return(false) }

      before { compte.valid? }

      it { expect(compte.errors[:email]).to include(I18n.t('errors.messages.invalid')) }
    end

    context "quand l'email du compte n'est pas modifié" do
      before { allow(compte).to receive(:email_changed?).and_return(false) }

      before { compte.valid? }

      it { expect(Truemail).not_to have_received(:valid?).with('email@example.com') }
    end
  end

  describe '#au_moins_admin?' do
    it { expect(Compte.new(role: 'superadmin').au_moins_admin?).to be(true) }
    it { expect(Compte.new(role: 'admin').au_moins_admin?).to be(true) }
    it { expect(Compte.new(role: 'compte_generique').au_moins_admin?).to be(true) }
    it { expect(Compte.new(role: 'conseiller').au_moins_admin?).to be(false) }
  end

  describe '#rejoindre_structure' do
    let(:structure) { Structure.new }
    let(:compte) { Compte.new statut_validation: nil, role: nil }

    before do
      allow(compte).to receive(:autres_admins?).and_return(true)
      compte.rejoindre_structure(structure)
    end

    it { expect(compte.structure).to eql(structure) }
    it { expect(compte.statut_validation).to eql('en_attente') }
    it { expect(compte.role).to eql('conseiller') }
  end

  describe "verifie la présence d'un admin" do
    let(:structure) { Structure.new }
    let(:compte) { Compte.new role: 'admin', structure: structure }

    before do
      allow(compte).to receive(:verifie_dns_email).and_return(true)
    end

    context 'quand il y a un autre admins dans la structure' do
      before do
        allow(compte).to receive(:autres_admins?).and_return(true)
      end

      it 'retire les droits à un admin' do
        compte.role = 'conseiller'
        compte.valid?
        expect(compte.errors[:role]).to be_blank
      end
    end

    context "quand il n'y a qu'un admin dans la structure" do
      before do
        allow(compte).to receive(:autres_admins?).and_return(false)
      end

      it 'ne peut pas retirer les droits de cet admin' do
        compte.role = 'conseiller'
        compte.valid?
        expect(compte.errors[:role]).to include 'La structure doit avoir au moins un administrateur'
      end
    end

    context "quand il n'y a pas d'admin dans la structure" do
      before do
        allow(compte).to receive(:autres_admins?).and_return(false)
      end

      it 'ajoute un admin' do
        compte.role = 'admin'
        compte.valid?
        expect(compte.errors[:role]).to be_blank
      end
    end

    context "Quand le compte n'a pas de structure" do
      it 'le compte peut avoir un rôle de conseiller' do
        compte.role = 'conseiller'
        compte.structure = nil
        compte.valid?
        expect(compte.errors[:role]).to be_blank
      end
    end
  end

  describe '#assigne_role_admin_si_pas_d_admin' do
    let(:structure) { Structure.new }
    let(:compte) { Compte.new role: 'conseiller' }

    context 'quand il y a un autre admins dans la structure' do
      before do
        allow(compte).to receive(:autres_admins?).and_return(true)
      end

      it "n'assigne pas le role admin" do
        compte.assigne_role_admin_si_pas_d_admin
        expect(compte.role).to eq 'conseiller'
        expect(compte.statut_validation).to eq 'en_attente'
      end
    end

    context "quand il n'y a pas d'admin dans la structure" do
      before do
        allow(compte).to receive(:autres_admins?).and_return(false)
      end

      it 'assigne le role admin' do
        compte.assigne_role_admin_si_pas_d_admin
        expect(compte.role).to eq 'admin'
        expect(compte.statut_validation).to eq 'acceptee'
      end
    end
  end
end
