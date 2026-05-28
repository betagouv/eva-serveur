require 'rails_helper'

RSpec.describe Evaluation::CompetenceTransversaleComponent, type: :component do
  subject(:component) do
    described_class.new(competence: :rapidite, interpretation: 5)
  end

  describe '#url_competence' do
    before { allow(ENV).to receive(:[]).and_call_original }

    it "construit l'url à partir de URL_SITE_VITRINE et du nom de page de la compétence" do
      allow(ENV).to receive(:[]).with('URL_SITE_VITRINE').and_return('https://site-vitrine.fr')

      expect(component.url_competence).to eq('https://site-vitrine.fr/vitesse-dexecution/')
    end
  end
end
