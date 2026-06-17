# frozen_string_literal: true

require "rails_helper"

RSpec.describe ResetPassword::PageContext do
  subject(:context) do
    described_class.new(
      action_name: action_name,
      token_invalide: token_invalide,
      reset_password_token: reset_password_token,
      resource_class: Compte
    )
  end

  let(:action_name) { "new" }
  let(:token_invalide) { false }
  let(:reset_password_token) { nil }

  describe "#state" do
    it "est request_email sur new sans token_invalide" do
      expect(context.state).to eq(:request_email)
    end

    context "sur edit avec token valide" do
      let(:action_name) { "edit" }
      let(:compte) { create(:compte) }
      let(:raw_token) do
        raw, hashed = Devise.token_generator.generate(Compte, :reset_password_token)
        compte.update!(reset_password_token: hashed, reset_password_sent_at: Time.zone.now.utc)
        raw
      end
      let(:reset_password_token) { raw_token }

      it "est change_password" do
        expect(context.state).to eq(:change_password)
      end
    end

    context "avec token_invalide" do
      let(:token_invalide) { true }

      it "est invalid_link" do
        expect(context.state).to eq(:invalid_link)
      end
    end
  end

  describe "#token_valide?" do
    let(:action_name) { "edit" }
    let(:compte) { create(:compte) }

    context "avec un token valide" do
      let(:raw_token) do
        raw, hashed = Devise.token_generator.generate(Compte, :reset_password_token)
        compte.update!(reset_password_token: hashed, reset_password_sent_at: Time.zone.now.utc)
        raw
      end
      let(:reset_password_token) { raw_token }

      it { expect(context.token_valide?).to be true }
    end

    context "avec un token inconnu" do
      let(:reset_password_token) { "invalide" }

      it { expect(context.token_valide?).to be false }
    end
  end

  describe "#redirect_path_si_token_invalide" do
    let(:action_name) { "edit" }
    let(:reset_password_token) { "invalide" }

    it "renvoie le chemin de renvoi email" do
      chemin_attendu = Rails.application.routes.url_helpers
        .new_compte_password_path(token_invalide: true)
      expect(context.redirect_path_si_token_invalide).to eq(chemin_attendu)
    end
  end
end
