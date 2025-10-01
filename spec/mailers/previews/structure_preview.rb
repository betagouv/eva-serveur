# Preview all emails at http://localhost:3000/rails/mailers/structure
class StructurePreview < ActionMailer::Preview
  def nouvelle_structure
    structure = Structure.first
    compte = Compte.new prenom: 'Paule', email: 'debut@test.com', structure: structure

    StructureMailer.with(structure: structure, compte: compte).nouvelle_structure
  end

  def relance_creation_campagne
    structure = StructureLocale.new id: SecureRandom.uuid, nom: 'Ma structure',
                                    code_postal: '92100', type_structure: 'mission_locale'
    compte_admin = Compte.new prenom: 'Jean', nom: 'Bon', email: 'compte_1@gmail.com',
                              structure: structure, role: 'admin'
    StructureMailer.with(compte_admin: compte_admin).relance_creation_campagne
  end
end
