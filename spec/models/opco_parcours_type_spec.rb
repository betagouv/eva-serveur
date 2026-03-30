
require 'rails_helper'

describe OpcoParcoursType, type: :model do
  let!(:opco_parcours_type) { create(:opco_parcours_type) }


  it { is_expected.to belong_to(:opco) }
  it { is_expected.to belong_to(:parcours_type) }

  it { expect(subject).to validate_uniqueness_of(:opco_id)
                  .scoped_to(:parcours_type_id)
                  .case_insensitive }
end
