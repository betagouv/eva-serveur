# frozen_string_literal: true

require 'rails_helper'

describe 'extraction:stats' do
  include_context 'rake'
  let(:logger) { RakeLogger.logger }

  context 'construit les noms de colonnes' do
    let(:colonnes) do
      {
        'maintenance' => %w[maintenance1 maintenance2],
        'livraison' => %w[livraison1],
        'bienvenue' => []
      }
    end
    let(:colonnes_z) do
      {
        'bienvenue' => [],
        'maintenance' => [],
        'livraison' => %w[livraison_z]
      }
    end
    it do
      expect(noms_colonnes('livraison', colonnes, colonnes_z))
        .to eq 'livraison: livraison1;livraison: cote_z_livraison_z;'
    end
  end
end
