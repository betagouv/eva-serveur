# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Contact, type: :model do
  it { should belong_to(:saisi_par).class_name('Compte').with_foreign_key('compte_id') }
end
