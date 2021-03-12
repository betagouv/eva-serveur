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
end
