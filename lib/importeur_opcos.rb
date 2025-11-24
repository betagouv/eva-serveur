require "rake_logger"
require "roo"

class ImporteurOpcos
  def importe
    chemin_fichier = Rails.root.join("config", "data", "tableau-correspondance-opco.xlsx")
    unless File.exist?(chemin_fichier)
      RakeLogger.logger.error("Fichier Excel introuvable : #{chemin_fichier}")
      exit 1
    end

    xlsx = Roo::Spreadsheet.open(chemin_fichier.to_s)
    sheet = xlsx.sheet(0)

    opcos_data = collecte_donnees_opcos(sheet)
    cree_ou_met_a_jour_opcos(opcos_data)
  end

  private

  def collecte_donnees_opcos(sheet)
    opcos_data = {}
    @nb_lignes_traitees = 0
    @nb_idcc_ignores = 0

    # La première ligne contient les headers, on commence à la ligne 2
    (2..sheet.last_row).each do |row_index|
      traite_ligne(sheet, row_index, opcos_data)
    end

    opcos_data
  end

  def traite_ligne(sheet, row_index, opcos_data)
    row = sheet.row(row_index)
    idcc = normalise_idcc(row[0])
    nom_opco = row[1]&.to_s&.strip

    return if nom_opco.blank?

    # Ignorer les IDCC "na" ou "N.A"
    if idcc_doit_etre_ignore?(idcc)
      @nb_idcc_ignores += 1
      return
    end

    opcos_data[nom_opco] ||= []
    opcos_data[nom_opco] << idcc unless opcos_data[nom_opco].include?(idcc)
    @nb_lignes_traitees += 1
  end

  def idcc_doit_etre_ignore?(idcc)
    idcc.blank? || idcc.downcase == "na" || idcc.downcase == "n.a"
  end

  def cree_ou_met_a_jour_opcos(opcos_data)
    nb_opcos_crees = 0
    nb_opcos_mis_a_jour = 0

    opcos_data.each do |nom_opco, idcc_list|
      if cree_opco(nom_opco, idcc_list)
        nb_opcos_crees += 1
      else
        nb_opcos_mis_a_jour += 1
      end
    end

    log_resume_import(nb_opcos_crees, nb_opcos_mis_a_jour)
  end

  def cree_opco(nom_opco, idcc_list)
    opco = Opco.find_or_initialize_by(nom: nom_opco)
    est_nouveau = opco.new_record?
    idcc_list_uniq = idcc_list.uniq.sort
    opco.idcc = idcc_list_uniq
    opco.save!

    message = est_nouveau ? "Créé Opco : #{nom_opco}" : "Mis à jour Opco : #{nom_opco}"
    RakeLogger.logger.info "#{message} avec #{idcc_list_uniq.size} IDCC"

    est_nouveau
  end

  def log_resume_import(nb_opcos_crees, nb_opcos_mis_a_jour)
    message = "Import terminé : #{nb_opcos_crees} créés, " \
              "#{nb_opcos_mis_a_jour} mis à jour, " \
              "#{@nb_lignes_traitees} lignes traitées, " \
              "#{@nb_idcc_ignores} IDCC ignorés"
    RakeLogger.logger.info message
  end

  def normalise_idcc(idcc)
    return nil if idcc.blank?

    # Convertir en string et supprimer les espaces
    idcc.to_s.strip
  end
end
