# frozen_string_literal: true

require 'rails_helper'

describe Restitution::StandardisateurEchantillon do
  describe 'retourne moyenne et écart type des scores CCF de toutes les Restitutions globales' do
    standardisateur = Restitution::StandardisateurEchantillon
                      .new %i[score_ccf], { score_ccf: [1, 2] }
    it { expect(standardisateur.moyennes_metriques).to eq(score_ccf: 1.5) }
    it { expect(standardisateur.ecarts_types_metriques).to eq(score_ccf: 0.5) }
  end

  describe "retourne nil si la métrique n'est pas présente" do
    standardisateur = Restitution::StandardisateurEchantillon
                      .new %i[score_ccf], { score_memorisation: [1, 2] }
    it { expect(standardisateur.moyennes_metriques).to eq(score_ccf: nil) }
    it { expect(standardisateur.ecarts_types_metriques).to eq(score_ccf: nil) }
  end

  describe 'sait standardiser une valeur' do
    standardisateur = Restitution::StandardisateurEchantillon
                      .new %i[score_ccf], { score_ccf: [1, 2] }

    it { expect(standardisateur.standardise(:score_ccf, 1)).to eq(-1.0) }
  end
end
