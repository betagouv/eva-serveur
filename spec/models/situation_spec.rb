require 'rails_helper'

RSpec.describe Situation, type: :model do
  it { is_expected.to validate_presence_of :libelle }
  it { is_expected.to validate_presence_of :nom_technique }
  it { is_expected.to validate_uniqueness_of :nom_technique }
  it { is_expected.to delegate_method(:livraison_sans_redaction?).to(:questionnaire).allow_nil }
end
