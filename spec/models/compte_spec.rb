# frozen_string_literal: true

require 'rails_helper'
require 'cancan/matchers'

describe Compte do
  it { should validate_inclusion_of(:role).in_array(%w[administrateur organisation]) }

  describe 'Gestion des droits' do
    subject(:ability) { Ability.new(compte) }

    context 'Compte administrateur' do
      let(:compte) { build :compte, role: 'administrateur' }

      it { is_expected.to be_able_to(:manage, :all) }
      it { is_expected.to_not be_able_to(%i[destroy create], Evaluation.new) }
      it { is_expected.to_not be_able_to(:create, Evenement.new) }
      it { is_expected.to be_able_to(:read, Evenement.new) }
      it { is_expected.to be_able_to(:manage, Campagne.new) }
      it { is_expected.to be_able_to(:manage, Questionnaire.new) }
    end

    context 'Compte organisation' do
      let(:compte) { build :compte, role: 'organisation' }

      it { is_expected.to_not be_able_to(:manage, Compte.new) }
      it { is_expected.to_not be_able_to(%i[destroy create update], Situation.new) }
      it { is_expected.to_not be_able_to(%i[destroy create update], Question.new) }
      it { is_expected.to_not be_able_to(:manage, Questionnaire.new) }
      it { is_expected.to be_able_to(:read, Questionnaire.new) }
    end
  end
end
