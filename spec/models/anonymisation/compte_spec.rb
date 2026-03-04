require 'rails_helper'

describe Anonymisation::Compte do
  describe '#anonymise' do
    let(:compte) do
      create :compte, prenom: 'toto', nom: 'dupont', telephone: '06…', email: 'toto@dupont.fr',
             id_pro_connect: 'un id', id_inclusion_connect: 'un id',
             fonction: 'directrice_ou_directeur', service_departement: 'Formation'
    end

    it 'anonymise avec un nom généré et supprime toutes données personnelles' do
      allow(FFaker::NameFR).to receive_messages(first_name: 'tata', last_name: 'dupuis')
      date_anonymisation = Time.zone.local(2025, 1, 2, 12, 0, 0)
      Timecop.freeze(date_anonymisation) do
        described_class.new(compte).anonymise
      end
      compte.reload
      expect(compte.anonymise_le).to eq(date_anonymisation)
      expect(compte.prenom).to eq 'tata'
      expect(compte.nom).to eq 'dupuis'
      expect(compte.email).to match(/tata\.dupuis\.\d{1,3}@anonyme\.fr/)
      expect(compte.telephone).to be_nil
      expect(compte.id_pro_connect).to be_nil
      expect(compte.id_inclusion_connect).to be_nil
      expect(compte.fonction).to be_nil
      expect(compte.service_departement).to be_nil
    end
  end
end
