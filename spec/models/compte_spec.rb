# frozen_string_literal: true

require 'rails_helper'

describe Compte do
  it { should validate_inclusion_of(:role).in_array(%w[administrateur organisation]) }
  it { should belong_to(:structure) }
  it { should validate_presence_of :statut_validation }
  it { should validate_presence_of :nom }
  it { should validate_presence_of :prenom }
  it do
    should define_enum_for(:statut_validation)
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
      .to eql('Pig - pepa@france5.fr')
  end
  it do
    expect(described_class.new(prenom: 'Pepa', nom: 'Pig', email: 'pepa@france5.fr').display_name)
      .to eql('Pepa Pig - pepa@france5.fr')
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
end
