# frozen_string_literal: true

require 'rails_helper'

describe DemandeAccompagnement, type: :model do
  it { should validate_presence_of :conseiller_nom }
  it { should validate_presence_of :conseiller_prenom }
  it { should validate_presence_of :conseiller_email }
  it { should validate_presence_of :conseiller_telephone }
  it { should validate_presence_of :probleme_rencontre }

  it { should belong_to(:compte) }
  it { should belong_to(:evaluation) }
end
