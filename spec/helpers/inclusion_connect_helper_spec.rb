# frozen_string_literal: true

require 'rails_helper'

describe InclusionConnectHelper do
  let(:email) { 'toto@eva.beta.gouv.fr' }
  let(:aujourdhui) { Time.zone.local(2023, 1, 10, 12, 0, 0) }
  let(:hier) { Time.zone.local(2023, 1, 9, 12, 0, 0) }

  describe '#cree_ou_recupere_compte' do
    context "le compte n'existe pas" do
      it do
        Timecop.freeze(aujourdhui) do
          compte = described_class.cree_ou_recupere_compte({
                                                             'email' => email,
                                                             'given_name' => 'prénom',
                                                             'family_name' => 'nom'
                                                           })
          expect(compte).not_to be_nil
          expect(compte.email).to eq(email)
          expect(compte.prenom).to eq('prénom')
          expect(compte.nom).to eq('nom')
          expect(compte.confirmed_at).to eq(aujourdhui)
        end
      end
    end

    context 'le compte existe déjà en base' do
      before do
        create :compte_admin, email: email
      end

      it do
        Timecop.freeze(aujourdhui) do
          compte = described_class.cree_ou_recupere_compte({
                                                             'email' => email,
                                                             'given_name' => 'prénom',
                                                             'family_name' => 'nom'
                                                           })
          expect(compte).not_to be_nil
          expect(compte.email).to eq(email)
          expect(compte.prenom).to eq('prénom')
          expect(compte.nom).to eq('nom')
          expect(compte.confirmed_at).to eq(aujourdhui)
        end
      end
    end

    context 'le compte existe déjà en base et avec un email déjà confirmé' do
      before do
        create :compte_admin, email: email, confirmed_at: hier
      end

      it do
        Timecop.freeze(aujourdhui) do
          compte = described_class.cree_ou_recupere_compte({
                                                             'email' => email,
                                                             'given_name' => 'prénom',
                                                             'family_name' => 'nom'
                                                           })
          expect(compte.confirmed_at).to eq(hier)
        end
      end
    end
  end
end
