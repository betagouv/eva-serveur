# frozen_string_literal: true

# Preview all emails at http://localhost:3000/rails/mailers/campagne_mailer
class CampagneMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/campagne_mailer/relance
  def relance
    structure = Structure.new type_structure: 'mission_locale'
    compte = Compte.new prenom: 'Lucas', structure: structure, email: 'lucas.dupont@example.com'
    campagne = Campagne.new compte: compte

    CampagneMailer.with(campagne: campagne).relance
  end
end
