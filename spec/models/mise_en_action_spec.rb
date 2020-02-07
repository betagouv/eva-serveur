# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MiseEnAction, type: :model do
  context 'avec recommandations_candidat' do
    before { allow(subject).to receive(:recommandations_candidat?).and_return(true) }
    it { should validate_presence_of :type_recommandation }
  end

  context 'sans recommandations_candidat' do
    before { allow(subject).to receive(:recommandations_candidat?).and_return(false) }
    it { should_not validate_presence_of :type_recommandation }
  end
end
