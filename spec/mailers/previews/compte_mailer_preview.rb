# frozen_string_literal: true

# Preview all emails at http://localhost:3000/rails/mailers/compte_mailer
class CompteMailerPreview < ActionMailer::Preview
  def nouveau_compte
    structure = Structure.new nom: 'Ma Super Structure', code_postal: '75012'
    compte = Compte.new prenom: 'Paule', email: 'debut@test.com', structure: structure
    CompteMailer.with(compte: compte).nouveau_compte
  end

  def alerte_admin
    structure = Structure.new nom: 'Ma Super Structure', code_postal: '75012'
    admin = Compte.new prenom: 'Admin', email: 'admin@test.com', structure: structure, role: 'admin'
    compte = Compte.new prenom: 'Paule',
                        nom: 'Delaporte',
                        email: 'debut@test.com',
                        structure: structure,
                        id: SecureRandom.uuid
    CompteMailer.with(compte: compte, compte_admin: admin).alerte_admin
  end

  def relance
    structure = Structure.new type_structure: 'mission_locale'
    compte = Compte.new prenom: 'Lucas', structure: structure, email: 'lucas.dupont@example.com'

    CompteMailer.with(compte: compte).relance
  end
end
