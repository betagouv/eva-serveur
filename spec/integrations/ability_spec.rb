# frozen_string_literal: true

require 'rails_helper'
require 'cancan/matchers'

describe Ability do
  let(:compte_administrateur) { create :compte, role: 'administrateur' }
  let(:compte_organisation) { create :compte, role: 'organisation' }

  subject(:ability) { Ability.new(compte) }

  context 'Compte administrateur' do
    let(:compte) { compte_administrateur }

    it { is_expected.to be_able_to(:manage, :all) }
    it do
      is_expected.to be_able_to(:read,
                                ActiveAdmin::Page,
                                name: 'Dashboard',
                                namespace_name: 'admin')
    end
    it { is_expected.to be_able_to(%i[read destroy], Evaluation.new) }
    it { is_expected.to_not be_able_to(%i[create update], Evaluation.new) }
    it { is_expected.to_not be_able_to(%i[create update], Evenement.new) }
    it { is_expected.to be_able_to(:read, Evenement.new) }
    it { is_expected.to be_able_to(:manage, Situation.new) }
    it { is_expected.to be_able_to(:manage, Campagne.new) }
    it { is_expected.to be_able_to(:manage, Questionnaire.new) }
    it { is_expected.to be_able_to(:manage, Question.new) }
    it { is_expected.to be_able_to(:manage, Restitution::Base.new(nil, nil)) }
  end

  context 'Compte organisation' do
    let(:compte) { compte_organisation }
    let(:campagne_compte) { Campagne.create(libelle: 'Nom', compte: compte) }
    let(:campagne_administrateur) { Campagne.create(libelle: 'Nom', compte: compte_administrateur) }
    let(:evaluation_autre_compte) { Evaluation.new(campagne: campagne_administrateur) }
    let(:evaluation_compte) { Evaluation.create(campagne: campagne_compte) }

    it { is_expected.to_not be_able_to(:manage, :all) }
    it do
      is_expected.to be_able_to(:read,
                                ActiveAdmin::Page,
                                name: 'Dashboard',
                                namespace_name: 'admin')
    end
    it { is_expected.to_not be_able_to(:manage, Compte.new) }
    it { is_expected.to_not be_able_to(%i[destroy create update], Situation.new) }
    it { is_expected.to_not be_able_to(%i[destroy create update], Question.new) }
    it { is_expected.to_not be_able_to(:manage, Questionnaire.new) }
    it { is_expected.to_not be_able_to(:manage, Campagne.new) }
    it { is_expected.to_not be_able_to(%i[create update], evaluation_compte) }
    it { is_expected.to_not be_able_to(%i[read destroy], evaluation_autre_compte) }
    it { is_expected.to_not be_able_to(:read, Evenement.new) }
    it { is_expected.to_not be_able_to(:read, Evenement.new(evaluation: evaluation_autre_compte)) }
    it { is_expected.to be_able_to(:read, Question.new) }
    it { is_expected.to be_able_to(%i[read destroy], evaluation_compte) }
    it { is_expected.to be_able_to(:read, Evenement.new(evaluation: evaluation_compte)) }
    it { is_expected.to be_able_to(:create, Campagne.new) }
    it { is_expected.to be_able_to(:manage, Campagne.new(compte: compte)) }
    it { is_expected.to be_able_to(:read, Questionnaire.new) }
    it { is_expected.to be_able_to(:read, Situation.new) }
    it { is_expected.to be_able_to(:manage, Restitution::Base.new(campagne_compte, nil)) }
  end
end
