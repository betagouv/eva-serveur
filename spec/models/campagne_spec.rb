# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Campagne, type: :model do
  it { should validate_presence_of :libelle }
  it { should validate_uniqueness_of :code }
  it { should belong_to(:questionnaire).optional }

  describe 'validation du code' do
    context 'garde le code initial' do
      let(:campagne) { Campagne.new code: 'mon code' }
      before { campagne.valid? }
      it { expect(campagne.code).to eq 'mon code' }
    end

    context 'sans code initial génère un code unique' do
      let(:campagne) { Campagne.new code: nil }
      before do
        allow(SecureRandom).to receive(:hex).with(3).and_return('abcde', '12345')
        allow(Campagne).to receive(:where).with(code: 'abcde').and_return(double(none?: false))
        allow(Campagne).to receive(:where).with(code: '12345').and_return(double(none?: true))
        campagne.valid?
      end
      it { expect(campagne.code).to eq '12345' }
    end
  end
end
