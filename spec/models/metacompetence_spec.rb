# frozen_string_literal: true

require 'rails_helper'

describe Metacompetence, type: :model do
  let(:metacompetences) do
    %w[numeratie
       ccf
       syntaxe-orthographe
       operations_addition
       operations_soustraction
       operations_multiplication
       operations_division
       denombrement
       ordonner_nombres_entiers
       ordonner_nombres_decimaux
       estimation
       proportionnalite
       resolution_de_probleme
       pourcentages
       unites_de_temps
       unites_de_temps_conversions
       plannings_lecture
       plannings_calculs
       renseigner_horaires
       unites_de_mesure
       instruments_de_mesure
       tableaux_graphiques
       surfaces
       perimetres
       volumes
       lecture_plan
       situation_dans_lespace
       reconnaitre_les_nombres
       vocabulaire_numeracie]
  end

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
