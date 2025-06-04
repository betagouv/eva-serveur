class CampagneDuplicateur
  def initialize(campagne, current_compte)
    @campagne = campagne
    @current_compte = current_compte
  end

  def duplique!
    @campagne_dupliquee = @campagne.dup
    assigne_libelle_copie
    assigne_type_programme
    reset_code
    duplique_situations_configurations
    assigne_compte_id
    @campagne_dupliquee.save!
    @campagne_dupliquee
  end

  private

  def reset_code
    @campagne_dupliquee.code = nil
  end

  def assigne_libelle_copie
    @campagne_dupliquee.libelle = libelle_copie_unique
  end

  def duplique_situations_configurations
    @campagne_dupliquee.situations_configurations =
      @campagne.situations_configurations.map do |config|
        situation_configuration_dupliquee = config.dup
        situation_configuration_dupliquee.campagne_id = @campagne_dupliquee.id
        situation_configuration_dupliquee
      end
  end

  def assigne_type_programme
    @campagne_dupliquee.type_programme =
      @campagne.parcours_type&.type_de_programme || ParcoursType::TYPES_DE_PROGRAMME.first
  end

  def assigne_compte_id
    @campagne_dupliquee.compte_id = @current_compte.id
  end

  def libelle_copie_unique
    base = "#{@campagne.libelle} - copie"

    existants = Campagne
      .where("libelle ILIKE ?", "#{base}%")
      .pluck(:libelle)

    return base unless existants.include?(base)

    max_suffix = existants.map do |libelle|
      libelle.match(/ - copie(?: (\d+))?$/)&.captures&.first&.to_i || 1
    end.max

    "#{base} #{max_suffix + 1}"
  end
end
