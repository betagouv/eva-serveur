require 'rails_helper'

describe Metacompetence, type: :model do
  describe '.code_clea_sous_domaine' do
    it "retourne le code cléa du sous domaine d'une métacompétence" do
      expect(described_class.code_clea_sous_domaine('operations_addition')).to eq('2.1')
    end

    it 'retourne nil si le code clea n\'est pas trouvé' do
      expect(described_class.code_clea_sous_domaine('toto')).to be_nil
    end
  end

  describe '.code_clea_sous_sous_domaine' do
    it "retourne le code cléa du sous sous domaine d'une métacompétence" do
      expect(described_class.code_clea_sous_sous_domaine('operations_addition')).to eq('2.1.1')
    end

    it 'retourne nil si le code clea n\'est pas trouvé' do
      expect(described_class.code_clea_sous_sous_domaine('toto')).to be_nil
    end
  end
end
