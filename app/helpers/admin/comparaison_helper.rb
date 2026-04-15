module Admin
  module ComparaisonHelper
    CORRESPONDANCES_PROFILS_LITTERATIE = {
      profil_4h: :profil4,
      profil_4h_plus: :profil4_plus,
      profil_4h_plus_plus: :profil4_plus_plus
    }.freeze

    def paragraphes_litteratie(tableau)
      paragraphes_par_competence(tableau, :litteratie)
    end

    def paragraphes_numeratie(tableau)
      paragraphes_par_competence(tableau, :numeratie)
    end

    private

    def paragraphes_par_competence(tableau, competence)
      passations = tableau.select { |ligne| ligne[:evaluation].present? }
      return [] if passations.empty?

      premiere_passation = passations.first
      deuxieme_passation = passations.second

      paragraphes = [
        construit_paragraphe(
          ligne: premiere_passation,
          competence: competence
        )
      ]

      if deuxieme_passation.present?
        paragraphes << construit_paragraphe(
          ligne: deuxieme_passation,
          competence: competence,
          profil_reference: premiere_passation[:profil]
        )
      end

      paragraphes
    end

    def construit_paragraphe(ligne:, competence:, profil_reference: nil)
      date = I18n.l(ligne[:evaluation].debutee_le, format: :sans_heure)

      profil_source = profil_source(competence, ligne[:profil])
      profil_reference_source = profil_source(competence, profil_reference)

      texte = if profil_reference.present? && profils_identiques?(competence, profil_source,
profil_reference_source)
                texte_identique(competence, profil_source)
      else
                texte_par_profil(competence, profil_source)
      end

      {
        date: date,
        texte: "la personne évaluée #{texte}"
      }
    end

    def profils_identiques?(competence, profil, profil_reference)
      profil_canonique(competence, profil) == profil_canonique(competence, profil_reference)
    end

    def texte_par_profil(competence, profil_source)
      profil_cle = profil_pour_texte(competence, profil_source)
      I18n.t("admin.comparaison.#{competence}.textes_profils.#{profil_cle}")
    end

    def texte_identique(competence, profil_source)
      cle_profil = "activerecord.attributes.evaluation.interpretations." \
                   "positionnement_niveau_#{competence}.#{profil_source}"
      profil_traduit = I18n.t(
        cle_profil
      )

      I18n.t("admin.comparaison.#{competence}.profils.identique", profil: profil_traduit)
    end

    def profil_source(competence, profil)
      valeur = (profil.presence || :indetermine).to_sym
      return :indetermine if competence == :numeratie && valeur == :profil_aberrant

      valeur
    end

    def profil_pour_texte(competence, profil_source)
      profil_canonique(competence, profil_source)
    end

    def profil_canonique(competence, profil_source)
      return profil_source unless competence == :litteratie

      CORRESPONDANCES_PROFILS_LITTERATIE.fetch(profil_source, profil_source)
    end
  end
end
