require 'rails_helper'

RSpec.describe Evaluation::NumeratieComponent, type: :component do
  context "quand il n'y a pas de restitution Place du marché" do
    let(:restitution_globale) do
      instance_double(Restitution::Globale, synthese_positionnement_numeratie: nil)
    end

    it do
      component = described_class.new restitution_globale: restitution_globale, place_du_marche: nil
      component_rendu = render_inline(component).to_html

      expect(component_rendu).to include('Calculer et raisonner - Numératie')
      expect(component_rendu).to include("Votre score n'a pas pu être calculé.")
      expect(component_rendu).to include('<img').and include('alt="Profil indéterminé"')
    end
  end
end
