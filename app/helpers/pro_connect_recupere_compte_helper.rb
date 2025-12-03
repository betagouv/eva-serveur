module ProConnectRecupereCompteHelper
  class << self
    def cree_ou_recupere_compte(user_info)
      email = user_info["email"].strip.downcase
      compte = Compte.find_by(id_pro_connect: user_info["sub"])
      if compte.present? && compte.email != email
        compte = actualise_email_compte_existant(compte, email)
      end
      if compte.blank? && email.end_with?("francetravail.fr")
        compte = cherche_compte_pole_emploi(email)
      end
      compte ||= Compte.find_or_create_by(email: email)
      actualise_autres_champs_et_sauve(compte, user_info)
    end

    private

    def actualise_email_compte_existant(compte, email)
      compte_existant = Compte.find_by(email: email)
      if compte_existant.present?
        compte.update!(id_pro_connect: nil)
        compte = compte_existant
      else
        compte.email = email
        compte.skip_reconfirmation!
        compte.confirmed_at = Time.zone.now
      end
      compte
    end

    def cherche_compte_pole_emploi(email)
      email_pe = email.gsub("francetravail.fr", "pole-emploi.fr")
      compte = Compte.find_by(email: email_pe)
      compte&.email = email
      compte&.skip_reconfirmation!
      compte&.confirmed_at = Time.zone.now
      compte
    end

    def actualise_autres_champs_et_sauve(compte, user_info)
      compte.assign_attributes(
        id_pro_connect: user_info["sub"],
        prenom: user_info["given_name"],
        nom: user_info["usual_name"],
        siret_pro_connect: user_info["siret"],
        confirmed_at: compte.confirmed_at || Time.zone.now
      )
      compte = assigne_structure_compte(compte, user_info)
      compte.password = SecureRandom.uuid if compte.encrypted_password.blank?
      compte.save!
      compte.assigne_preinscription
      compte
    end

    def assigne_structure_compte(compte, user_info)
      structure = cherche_structure_avec_siret_pro_connect(user_info["siret"])
      compte.structure = structure if structure.present?
    end

    def cherche_structure_avec_siret_pro_connect(siret)
      Structure.find_by(siret: siret)
    end
  end
end
