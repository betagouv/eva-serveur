# frozen_string_literal: true

require 'rails_helper'

describe Metacompetence, type: :model do
  let(:metacompetences) do
    %w[numeratie ccf syntaxe-orthographe operations_addition operations_soustraction
       operations_multiplication operations_division denombrement ordonner_nombres_entiers
       ordonner_nombres_decimaux operations_nombres_entiers estimation proportionnalite
       resolution_de_probleme pourcentages unites_temps unites_de_temps_conversions plannings
       plannings_calculs renseigner_horaires unites_de_mesure instruments_de_mesure
       tableaux_graphiques surfaces perimetres perimetres_surfaces volumes lecture_plan
       situation_dans_lespace reconnaitre_les_nombres reconaitre_les_nombres vocabulaire_numeracie]
  end

  it 'retourne toutes les métacompétences' do
    expect(Metacompetence::METACOMPETENCES).to eq(metacompetences)
  end
end
