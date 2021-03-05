# frozen_string_literal: true

require 'rails_helper'

describe Compte do
  it { should validate_inclusion_of(:role).in_array(%w[administrateur organisation]) }
  it { should belong_to(:structure) }
  it { should validate_presence_of :statut_validation }
  it do
    should define_enum_for(:statut_validation)
      .with_values(%i[en_attente acceptee refusee])
      .with_prefix(:validation)
  end
end
