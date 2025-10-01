require 'rails_helper'
require 'cancan/matchers'

describe AbilityUtilisateur do
  subject(:ability) { described_class.new(compte) }

  let(:structure) { create(:structure_locale, :avec_admin) }
  let(:compte) { create(:compte, role: :admin, structure: structure) }


  describe '#can_update_active_pour_campagne?' do
    let(:campagne) { create(:campagne) }

    context 'quand le compte est au moins admin' do
      it do
        expect(ability).to be_can_update_active_pour_campagne(campagne)
      end
    end

    context 'quand le compte est le propriétaire de la campagne' do
      let(:compte) { create(:compte, role: :conseiller, structure: structure) }
      let(:campagne) { create(:campagne, compte: compte) }

      it do
        expect(ability).to be_can_update_active_pour_campagne(campagne)
      end
    end

    context "quand le compte n'est ni propriétaire, ni admin" do
      let(:compte) { create(:compte, role: :conseiller, structure: structure) }

      it do
        expect(ability).not_to be_can_update_active_pour_campagne(campagne)
      end
    end
  end
end
