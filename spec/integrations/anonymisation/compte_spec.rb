# frozen_string_literal: true

require 'rails_helper'

describe Anonymisation::Compte, type: :integration do
  let(:compte) do
    create :compte, anonymise_le: nil,
                    prenom: 'Clément',
                    nom: 'Dupont',
                    telephone: '0606062929',
                    email: 'clement.dupont@gmail.com'
  end

  it 'anonymise le compte' do
    Anonymisation::Compte.new(compte).anonymise

    compte.reload
    expect(compte.anonymise_le).not_to be_nil
    expect(compte.prenom).not_to eq 'Clément'
    expect(compte.nom).not_to eq 'Dupont'
    expect(compte.telephone).to be_nil
    expect(compte.email).not_to eq 'clement.dupont@gmail.com'
  end
end
