require 'rails_helper'

describe GeolocHelper, type: :model do
  describe '.departement' do
    it 'retourne les 2 premiers caractères pour un code postal métropolitain' do
      expect(described_class.departement('45300')).to eql('45')
    end

    it 'retourne les 3 premiers caractères pour un DOM commençant par 97' do
      expect(described_class.departement('97100')).to eql('971')
    end

    it 'retourne les 3 premiers caractères pour un DOM commençant par 98' do
      expect(described_class.departement('98800')).to eql('988')
    end

    it 'retourne 2A pour un code postal commençant par 20 (Corse)' do
      expect(described_class.departement('20000')).to eql('2A')
    end

    it "retourne 'non_communique' si le code postal est 'non_communique'" do
      expect(described_class.departement('non_communique')).to eql('non_communique')
    end
  end

  describe '.cherche_region' do
    it { expect(described_class.cherche_region(nil)).to be_nil }

    context "quand l'api departements retourne une 404" do
      it { expect(described_class.cherche_region('99999')).to be_nil }
      it { expect(described_class.cherche_region('non_communique')).to be_nil }
    end

    it "retourne la region d'un code postal" do
      mock_reponse_typhoeus('https://geo.api.gouv.fr/departements/45',
                            { codeRegion: 24 })

      mock_reponse_typhoeus('https://geo.api.gouv.fr/regions/24',
                            { nom: 'Centre-Val de Loire' })

      expect(described_class.cherche_region('45300')).to eql('Centre-Val de Loire')
    end

    it 'retourne nil quand il trouve le département, mais pas la région' do
      mock_reponse_typhoeus('https://geo.api.gouv.fr/departements/45',
                            { codeRegion: 24 })

      expect(described_class.cherche_region('45300')).to be_nil
    end
  end

  describe '.cherche_code_commune' do
    it { expect(described_class.cherche_code_commune(nil)).to be_nil }

    it "retourne le code commune d'un code postal" do
      mock_reponse_typhoeus('https://geo.api.gouv.fr/communes?codePostal=45300',
                            [ { code: '45273', nom: 'Pithiviers' } ])

      expect(described_class.cherche_code_commune('45300')).to eql('45273')
    end

    it 'retourne nil quand le code postal ne correspond à aucune commune' do
      mock_reponse_typhoeus('https://geo.api.gouv.fr/communes?codePostal=99999', [])

      expect(described_class.cherche_code_commune('99999')).to be_nil
    end
  end
end
