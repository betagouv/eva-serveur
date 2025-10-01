require 'rails_helper'

describe ParcoursType, type: :model do
  it { is_expected.to validate_presence_of :libelle }
  it { is_expected.to validate_presence_of :duree_moyenne }
  it { is_expected.to validate_presence_of :nom_technique }
  it { is_expected.to validate_uniqueness_of :nom_technique }

  it 'retourne false lorsque la configuration du parcours type ne contient pas la livraison' do
    parcours_type_sans_livraison = create :parcours_type
    expect(parcours_type_sans_livraison.option_redaction?).to be(false)
  end

  it 'retourne true lorsque la configuration du parcours type contient la livraison' do
    parcours_type_avec_livraison = create :parcours_type, :competences_de_base
    expect(parcours_type_avec_livraison.option_redaction?).to be(true)
  end

  it do
    expect(subject)
      .to have_many(:situations_configurations).order(position: :asc).dependent(:destroy)
  end
end
