# frozen_string_literal: true

require 'rails_helper'

describe Compte, type: :integration do
  ActiveJob::Base.queue_adapter = :test

  describe 'après création' do
    it 'programme un mail de relance' do
      expect do
        create :compte
      end.to have_enqueued_job(RelanceUtilisateurPourNonActivationJob)
    end
  end
end
