require 'rails_helper'

describe 'Admin - Compte', type: :request do
  let(:ma_structure) { create :structure_locale }
  let(:autre_structure) { create :structure_locale, :avec_admin }
  let!(:admin) { create :compte_admin, structure: ma_structure }
  let(:nouveau_mot_de_passe) { 'NouveauMotDePasse123$' }

  def modifie(compte, attributs)
    patch admin_compte_path(compte), params: { compte: attributs }
    compte.reload
  end

  context 'en conseiller' do
    let(:conseiller) { create :compte_conseiller, structure: ma_structure }

    before { sign_in conseiller }

    it 'ne peut pas changer son propre rôle' do
      expect(modifie(conseiller, role: 'superadmin').role).to eq 'conseiller'
      expect(modifie(conseiller, role: 'admin').role).to eq 'conseiller'
    end

    it 'ne peut pas changer de structure' do
      expect(modifie(conseiller, structure_id: autre_structure.id).structure).to eq ma_structure
    end

    it 'peut modifier ses informations et son mot de passe' do
      modifie(conseiller, prenom: 'Robert', password: nouveau_mot_de_passe,
                          password_confirmation: nouveau_mot_de_passe)

      expect(conseiller.prenom).to eq 'Robert'
      expect(conseiller.valid_password?(nouveau_mot_de_passe)).to be true
    end

    context "quand son compte est en attente de validation" do
      let(:conseiller) { create :compte_conseiller, :en_attente, structure: ma_structure }

      it 'ne peut pas valider son propre compte' do
        expect(modifie(conseiller, statut_validation: 'acceptee')).to be_validation_en_attente
      end
    end
  end

  context 'en admin de structure' do
    let(:collegue) { create :compte_conseiller, structure: ma_structure }

    before { sign_in admin }

    it 'peut donner un rôle de structure à un collègue' do
      expect(modifie(collegue, role: 'admin').role).to eq 'admin'
    end

    it 'ne peut pas donner un rôle réservé aux superadmins' do
      expect(modifie(collegue, role: 'superadmin').role).to eq 'conseiller'
      expect(modifie(collegue, role: 'compte_generique').role).to eq 'conseiller'
      expect(modifie(admin, role: 'superadmin').role).to eq 'admin'
    end

    it 'peut refuser un collègue' do
      expect(modifie(collegue, statut_validation: 'refusee')).to be_validation_refusee
    end

    it 'ne peut pas changer son propre statut de validation' do
      expect(modifie(admin, statut_validation: 'refusee')).to be_validation_acceptee
    end

    it "ne peut pas changer le mot de passe d'un collègue" do
      modifie(collegue, password: nouveau_mot_de_passe, password_confirmation: nouveau_mot_de_passe)

      expect(collegue.valid_password?(nouveau_mot_de_passe)).to be false
    end

    it 'ne peut pas déplacer un collègue dans une autre structure' do
      expect(modifie(collegue, structure_id: autre_structure.id).structure).to eq ma_structure
    end

    describe 'création de compte' do
      let(:attributs) do
        { email: 'collegue@exemple.fr', prenom: 'Peppa', nom: 'Pig',
          password: nouveau_mot_de_passe, password_confirmation: nouveau_mot_de_passe,
          structure_id: ma_structure.id }
      end

      def cree(attributs)
        post admin_comptes_path, params: { compte: attributs }
        Compte.find_by(email: 'collegue@exemple.fr')
      end

      it 'peut créer un collègue admin dans sa structure' do
        compte = cree(attributs.merge(role: 'admin'))

        expect(compte.role).to eq 'admin'
        expect(compte.structure).to eq ma_structure
      end

      it 'ne peut pas créer un superadmin' do
        expect(cree(attributs.merge(role: 'superadmin')).role).to eq 'conseiller'
      end

      it 'ne peut pas créer un compte dans une autre structure' do
        compte = cree(attributs.merge(structure_id: autre_structure.id))

        expect(compte&.structure).not_to eq autre_structure
      end
    end

    describe 'vérification depuis la modale' do
      let(:collegue) { create :compte_conseiller, :en_attente, structure: ma_structure }

      def verifie(role)
        patch verifier_admin_compte_path(collegue),
              params: { decision: 'Autoriser', role: role },
              headers: { 'HTTP_REFERER' => admin_comptes_path }
        collegue.reload
      end

      it 'peut autoriser un collègue avec un rôle de structure' do
        expect(verifie('admin').role).to eq 'admin'
        expect(collegue).to be_validation_acceptee
      end

      it 'ne peut pas autoriser un collègue avec un rôle réservé aux superadmins' do
        expect(verifie('superadmin').role).to eq 'conseiller'
      end
    end
  end

  context 'en superadmin' do
    let(:superadmin) { create :compte_superadmin, structure: ma_structure }
    let(:collegue) { create :compte_conseiller, structure: ma_structure }

    before { sign_in superadmin }

    it 'peut donner tous les rôles' do
      expect(modifie(collegue, role: 'superadmin').role).to eq 'superadmin'
    end

    it 'peut déplacer un compte dans une autre structure' do
      expect(modifie(collegue, structure_id: autre_structure.id).structure).to eq autre_structure
    end

    it "peut changer le mot de passe d'un autre compte" do
      modifie(collegue, password: nouveau_mot_de_passe, password_confirmation: nouveau_mot_de_passe)

      expect(collegue.valid_password?(nouveau_mot_de_passe)).to be true
    end
  end
end
