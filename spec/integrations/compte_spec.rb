# frozen_string_literal: true

require 'rails_helper'

describe Compte, type: :integration do
  ActiveJob::Base.queue_adapter = :test

  describe 'après création' do
    it 'programme un mail de relance' do
      expect do
        create :compte_conseiller
      end.to have_enqueued_job(RelanceUtilisateurPourNonActivationJob)
    end

    context 'quand le compte est superadmin' do
      it 'ne programme pas de mail de relance' do
        expect do
          create :compte_superadmin
        end.not_to have_enqueued_job(RelanceUtilisateurPourNonActivationJob)
      end
    end
  end
end
