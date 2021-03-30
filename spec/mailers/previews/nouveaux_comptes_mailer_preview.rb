# frozen_string_literal: true

# Preview all emails at http://localhost:3000/rails/mailers/nouveaux_comptes_mailer
class NouveauxComptesMailerPreview < ActionMailer::Preview
  def email_nouveau_compte
    structure = Structure.new nom: 'Ma Super Structure'
    compte = Compte.new prenom: 'Paule', email: 'debut@test.com', structure: structure
    campagne = Campagne.new compte: compte, libelle: 'Paris 2019', code: 'paris2019'
    NouveauxComptesMailer.with(campagne: campagne).email_nouveau_compte
  end
end
