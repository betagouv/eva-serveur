# frozen_string_literal: true

require 'rails_helper'

describe InclusionConnectHelper do
  let(:email) { 'toto@eva.beta.gouv.fr' }
  let(:ancien_email) { 'autre@eva.beta.gouv.fr' }
  let(:aujourdhui) { Time.zone.local(2023, 1, 10, 12, 0, 0) }
  let(:hier) { Time.zone.local(2023, 1, 9, 12, 0, 0) }

  describe '#logout' do
    it "construit l'url de deconnexion et nettoie la session" do
      stub_const('::IC_BASE_URL', 'https://IC_HOST')
      session = {
        ic_state: 'STATE',
        ic_logout_token: 'TOKEN'
      }
      expect(described_class.logout(session, 'https://post_logout_uri'))
        .to eq('https://IC_HOST/auth/logout?id_token_hint=TOKEN&post_logout_redirect_uri=https%3A%2F%2Fpost_logout_uri&state=STATE')
      expect(session[:ic_logout_token]).to be_nil
    end
  end

  describe '#cree_ou_recupere_compte' do
    let(:id_ic) { 'identifiant_ic' }

    context "le compte n'existe pas" do
      it do
        Timecop.freeze(aujourdhui) do
          compte = described_class.cree_ou_recupere_compte({
                                                             'sub' => id_ic,
                                                             'email' => email,
                                                             'given_name' => 'prénom',
                                                             'family_name' => 'nom'
                                                           })
          expect(compte).not_to be_nil
          expect(compte.email).to eq(email)
          expect(compte.prenom).to eq('prénom')
          expect(compte.nom).to eq('nom')
          expect(compte.confirmed_at).to eq(aujourdhui)
          expect(compte.password).not_to be_nil
          expect(compte.id_inclusion_connect).to eq(id_ic)
        end
      end
    end

    context 'le compte existe déjà en base sans id inclusion connect' do
      before do
        create :compte_admin, email: email
      end

      it do
        Timecop.freeze(aujourdhui) do
          compte = described_class.cree_ou_recupere_compte({
                                                             'sub' => id_ic,
                                                             'email' => email,
                                                             'given_name' => 'prénom',
                                                             'family_name' => 'nom'
                                                           })
          expect(compte).not_to be_nil
          expect(compte.email).to eq(email)
          expect(compte.prenom).to eq('prénom')
          expect(compte.nom).to eq('nom')
          expect(compte.confirmed_at).to eq(aujourdhui)
          expect(compte.password).to be_nil
          expect(compte.id_inclusion_connect).to eq(id_ic)
        end
      end
    end

    context 'le compte existe déjà en base sans id inclusion connect, email avec majuscule' do
      before do
        create :compte_admin, email: email
      end

      it do
        Timecop.freeze(aujourdhui) do
          compte = described_class.cree_ou_recupere_compte({
                                                             'sub' => id_ic,
                                                             'email' => 'toto@eva.beta.gouv.FR',
                                                             'given_name' => 'prénom',
                                                             'family_name' => 'nom'
                                                           })
          expect(compte).not_to be_nil
          expect(compte.email).to eq(email)
          expect(compte.prenom).to eq('prénom')
          expect(compte.nom).to eq('nom')
          expect(compte.confirmed_at).to eq(aujourdhui)
          expect(compte.password).to be_nil
          expect(compte.id_inclusion_connect).to eq(id_ic)
        end
      end
    end

    context 'le compte existe déjà en base même email, mais effacé' do
      before do
        create :compte_admin, email: email, confirmed_at: hier, deleted_at: hier
      end

      it do
        Timecop.freeze(aujourdhui) do
          compte = described_class.cree_ou_recupere_compte({
                                                             'sub' => id_ic,
                                                             'email' => email,
                                                             'given_name' => 'prénom',
                                                             'family_name' => 'nom'
                                                           })
          expect(compte).not_to be_nil
          expect(compte.prenom).to eq('prénom')
          expect(compte.nom).to eq('nom')
          expect(compte.email).to eq(email)
          expect(compte.confirmed_at).to eq(aujourdhui)
          expect(compte.password).not_to be_nil
          expect(compte.id_inclusion_connect).to eq(id_ic)
          expect(compte.id).not_to eq(Compte.only_deleted.find_by(email: email).id)
        end
      end
    end

    context 'le compte existe déjà en base avec id inclusion connect, même email' do
      before do
        create :compte_admin, email: email, confirmed_at: hier, id_inclusion_connect: id_ic
      end

      it do
        Timecop.freeze(aujourdhui) do
          compte = described_class.cree_ou_recupere_compte({
                                                             'sub' => id_ic,
                                                             'email' => email,
                                                             'given_name' => 'prénom',
                                                             'family_name' => 'nom'
                                                           })
          expect(compte).not_to be_nil
          expect(compte.prenom).to eq('prénom')
          expect(compte.nom).to eq('nom')
          expect(compte.email).to eq(email)
          expect(compte.confirmed_at).to eq(hier)
          expect(compte.password).to be_nil
          expect(compte.id_inclusion_connect).to eq(id_ic)
        end
      end
    end

    context 'le compte existe déjà en base avec id inclusion connect, email différent' do
      before do
        create :compte_admin, email: ancien_email, confirmed_at: hier, id_inclusion_connect: id_ic
      end

      it do
        Timecop.freeze(aujourdhui) do
          compte = described_class.cree_ou_recupere_compte({
                                                             'sub' => id_ic,
                                                             'email' => email,
                                                             'given_name' => 'prénom',
                                                             'family_name' => 'nom'
                                                           })
          expect(compte).not_to be_nil
          expect(compte.prenom).to eq('prénom')
          expect(compte.nom).to eq('nom')
          expect(compte.email).to eq(email)
          expect(compte.confirmed_at).to eq(aujourdhui)
          expect(compte.password).to be_nil
          expect(compte.id_inclusion_connect).to eq(id_ic)
        end
      end
    end

    context "Il existe deux comptes en base dans le cas d'une mise à jourd d'email" do
      before do
        create :compte_admin, email: email, confirmed_at: hier
        create :compte_admin, email: ancien_email, confirmed_at: hier, id_inclusion_connect: id_ic
      end

      it do
        Timecop.freeze(aujourdhui) do
          compte = described_class.cree_ou_recupere_compte({
                                                             'sub' => id_ic,
                                                             'email' => email,
                                                             'given_name' => 'prénom',
                                                             'family_name' => 'nom'
                                                           })
          expect(compte).not_to be_nil
          expect(compte.prenom).to eq('prénom')
          expect(compte.nom).to eq('nom')
          expect(compte.email).to eq(email)
          expect(compte.confirmed_at).to eq(hier)
          expect(compte.password).to be_nil
          expect(compte.id_inclusion_connect).to eq(id_ic)
          ancien_compte = Compte.find_by(email: ancien_email)
          expect(ancien_compte).not_to be_nil
          expect(ancien_compte.id_inclusion_connect).to be_nil
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
                                                             'sub' => id_ic,
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
