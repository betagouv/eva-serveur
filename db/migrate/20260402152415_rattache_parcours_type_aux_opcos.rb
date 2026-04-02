class RattacheParcoursTypeAuxOpcos < ActiveRecord::Migration[7.2]
  def up
    mapping_opcos_parcours_types = {
        "ANFH" => ["eva-entreprise-anfh"],
        "Constructys" => ["eva-entreprise-constructys__BTP", "eva-entreprise-constructys__NMC"],
        "OPCO EP" => ["eva-entreprise-opcoep"],
        "OPCO Santé" => ["eva-entreprise-opcosante"],
        "AFDAS" => ["eva-entreprise-afdas"],
        "OPCO Mobilités" => ["eva-entreprise-opcomobilites"],
        "OPCO ATLAS" => ["eva-entreprise"],
        "OPCOMMERCE" => ["eva-entreprise"],
        "OCAPIAT" => ["eva-entreprise"],
        "Uniformation" => ["eva-entreprise"],
        "OPCO 2i" => ["eva-entreprise"],
        "Akto" => ["eva-entreprise"],
        "CNFPT" => ["eva-entreprise"],
        "Aucun OPCO de rattachement" => ["eva-entreprise"]
      }

    opcos_parcours_types_crees = []
    errors = []

    # Normalisation pour matcher prod/preprod
    def normalize(str)
      I18n.transliterate(str.to_s).downcase.gsub(/\s+/, '')
    end

    # Index des OPCO par nom normalisé
    opcos_par_nom_normalise = Opco.all.index_by { |o| normalize(o.nom) }

    mapping_opcos_parcours_types.each do |nom_opco, parcours_types_noms_technique|
      opco = opcos_par_nom_normalise[normalize(nom_opco)]
      unless opco
        errors << "OPCO introuvable: #{nom_opco}"
        next
      end

      parcours_types_noms_technique.each do |parcours_type_nom_technique|
        parcours_type = ParcoursType.find_by(nom_technique: parcours_type_nom_technique)
        unless parcours_type
          errors << "ParcoursType introuvable: #{parcours_type_nom_technique} (OPCO: #{nom_opco})"
          next
        end

        association = OpcoParcoursType.find_or_initialize_by(
          opco: opco,
          parcours_type: parcours_type
        )

        if association.new_record?
          if association.save
            opcos_parcours_types_crees << association
          else
            errors << "Erreur association: #{nom_opco} -> #{parcours_type_nom_technique} (#{association.errors.full_messages.join(', ')})"
          end
        end
      rescue StandardError => e
        errors << "Erreur association: #{nom_opco} -> #{parcours_type_nom_technique} (#{e.message})"
      end
    end

    Rails.logger.info "Associations créées: #{opcos_parcours_types_crees.count}"
    if errors.any?
      Rails.logger.warn "Erreurs rencontrées:"
      errors.uniq.each { |error| Rails.logger.warn "  - #{error}" }
    end
  end

  def down; end
end
