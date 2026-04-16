class Evaluation
  class AnnexePositionnementEvaComponent < ViewComponent::Base
    include MarkdownHelper

    def initialize(nom_beneficiaire:, code_beneficiaire:, date: nil, structure: nil)
      @entete_page_args = {
        nom_beneficiaire: nom_beneficiaire,
        code_beneficiaire: code_beneficiaire,
        date: date,
        structure: structure
      }

      @badges_numeratie = %i[profil1 profil2 profil3 profil4 profil4_plus]
      @badges_litteratie = %i[profil1 profil2 profil3 profil4 profil4_plus profil4_plus_plus]
      @scope_badge = "admin.restitutions.references"
    end
  end
end
