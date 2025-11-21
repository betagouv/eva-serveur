class AffiliationOpcoService
  CHEMIN_FICHIER_MAPPING = Rails.root.join("docs", "tableau-correspondance-opco.xlsx").freeze

  def initialize(structure)
    @structure = structure
    @mapping_cache = nil
  end

  def affilie_opcos
    return if @structure.idcc.blank?

    opcos_trouves = trouve_opcos_par_idcc
    return if opcos_trouves.empty?

    opcos_trouves.each do |opco|
      @structure.structure_opcos.find_or_create_by(opco: opco)
    end
  end

  private

  def trouve_opcos_par_idcc
    return [] if @structure.idcc.blank?

    opcos_ids = []
    @structure.idcc.each do |idcc|
      idcc_normalise = normalise_idcc(idcc)
      next if idcc_normalise.blank?

      nom_opco = mapping_idcc_opco[idcc_normalise]
      next if nom_opco.blank?

      opco = Opco.find_by(nom: nom_opco)
      opcos_ids << opco.id if opco.present?
    end

    Opco.where(id: opcos_ids.uniq)
  end

  def mapping_idcc_opco
    @mapping_cache ||= charger_mapping
  end

  def charger_mapping
    return {} unless File.exist?(CHEMIN_FICHIER_MAPPING)

    xlsx = Roo::Spreadsheet.open(CHEMIN_FICHIER_MAPPING.to_s)
    sheet = xlsx.sheet(0)

    construire_mapping_depuis_sheet(sheet)
  rescue StandardError => e
    Rails.logger.error("Erreur lors du chargement du mapping OPCO: #{e.message}")
    {}
  end

  def construire_mapping_depuis_sheet(sheet)
    mapping = {}
    # La première ligne contient les headers, on commence à la ligne 2
    (2..sheet.last_row).each do |row_index|
      row = sheet.row(row_index)
      idcc = normalise_idcc(row[0])
      nom_opco = row[1]&.to_s&.strip

      next if idcc.blank? || nom_opco.blank?

      mapping[idcc] = nom_opco
    end

    mapping
  end

  def normalise_idcc(idcc)
    return nil if idcc.blank?

    # Convertir en string et supprimer les espaces
    idcc.to_s.strip
  end
end
