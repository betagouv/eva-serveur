# frozen_string_literal: true

# Preview all emails at http://localhost:3000/rails/mailers/structure
class StructurePreview < ActionMailer::Preview
  def nouvelle_structure
    id = SecureRandom.uuid
    structure = Structure.new nom: 'Ma Super Structure', id: id
    compte = Compte.new prenom: 'Paule', email: 'debut@test.com', structure: structure

    StructureMailer.with(structure: structure, compte: compte).nouvelle_structure
  end
end
