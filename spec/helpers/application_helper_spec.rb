require 'rails_helper'

describe ApplicationHelper do
  describe '#formate_efficience' do
    it 'retourne le pourcentage arrondi' do
      expect(helper.formate_efficience(5.3)).to eql('5%')
    end

    it 'retourne la chaine indéterminé traduite' do
      expect(helper.formate_efficience(Competence::NIVEAU_INDETERMINE))
        .to eql(I18n.t('admin.restitutions.evaluation.indetermine'))
    end
  end

  describe '#formate_duree' do
    it 'retourne la durée en minutes et secondes' do
      expect(helper.formate_duree(60)).to eql('01:00')
    end

    it 'retourne une autre durée en minutes et secondes' do
      expect(helper.formate_duree(30)).to eql('00:30')
    end

    it 'retourne une durée en heure, minutes et secondes' do
      expect(helper.formate_duree(3661)).to eql('01:01:01')
    end

    it 'retourne une durée en heure, minutes et secondes pour une durée de plus de 24 heures' do
      expect(helper.formate_duree((24 * 60 * 60) + 3661)).to eql('25:01:01')
    end

    it 'même si la durée est un décimal' do
      expect(helper.formate_duree(88_928.781648)).to eql('24:42:08')
      expect(helper.formate_duree(276.439082)).to eql('04:36')
    end

    it 'retourne nil si le paramètre est vide' do
      expect(helper.formate_duree('')).to be_nil
    end

    it 'retourne une durée negative' do
      expect(helper.formate_duree(-8.300185)).to eql('-00:08')
    end
  end

  describe '#cdn_for(fichier)' do
    let(:fichier) { double('fichier') }

    before do
      allow(ENV).to receive(:fetch).with('PROTOCOLE_SERVEUR').and_return('https')
      allow(ENV).to receive(:fetch).with('HOTE_STOCKAGE').and_return('stockage.eva.ancli.gouv.fr')

      allow(fichier).to receive_messages(filename: 'fichier.jpg', key: 'ma_cle')
    end

    context 'en environnement de production' do
      before do
        environnement = double('env')
        allow(Rails).to receive(:env).and_return(environnement)
        allow(environnement).to receive(:production?).and_return(true)
      end

      it 'retourne une url avec le nom du fichier pour y accéder' do
        url = 'https://stockage.eva.ancli.gouv.fr/ma_cle?filename=fichier.jpg'
        expect(helper.cdn_for(fichier)).to eq url
      end
    end
  end

  describe '#partenaires_opcos_financeurs' do
    context 'quand le compte est nil' do
      it 'retourne une liste vide' do
        expect(helper.partenaires_opcos_financeurs(nil)).to eq([])
      end
    end

    context 'quand le compte n\'a pas de structure' do
      let(:compte) { create(:compte_pro_connect) }

      it 'retourne une liste vide' do
        expect(helper.partenaires_opcos_financeurs(compte)).to eq([])
      end
    end

    context 'quand la structure n\'a pas d\'opcos' do
      let(:compte) { create(:compte) }

      it 'retourne une liste vide' do
        expect(helper.partenaires_opcos_financeurs(compte)).to eq([])
      end
    end

    context 'quand la structure a un opco non financeur' do
      let(:compte) { create(:compte) }
      let(:opco_non_financeur) { create(:opco, :opco_non_financeur) }

      before do
        compte.structure.update!(opco: opco_non_financeur)
      end

      it 'retourne une liste vide' do
        expect(helper.partenaires_opcos_financeurs(compte)).to eq([])
      end
    end

    context 'quand la structure a un opco financeur sans logo' do
      let(:compte) { create(:compte) }
      let(:opco_financeur) { create(:opco, financeur: true, nom: 'OPCO Financeur') }

      before do
        compte.structure.update!(opco: opco_financeur)
      end

      it 'retourne une liste vide' do
        expect(helper.partenaires_opcos_financeurs(compte)).to eq([])
      end
    end

    context 'quand la structure a un opco financeur avec logo' do
      let(:compte) { create(:compte) }
      let(:opco_financeur) { create(:opco, financeur: true, nom: 'OPCO Financeur', url: 'https://example.com') }
      let(:logo_file) { Rack::Test::UploadedFile.new(Rails.root.join('spec', 'support', 'programme_tele.png'), 'image/png') }

      before do
        compte.structure.update!(opco: opco_financeur)
        opco_financeur.logo.attach(logo_file)
      end

      it 'retourne un tableau avec les informations du partenaire' do
        resultat = helper.partenaires_opcos_financeurs(compte)

        expect(resultat).to be_an(Array)
        expect(resultat.length).to eq(1)
        expect(resultat.first).to include(:logo, :nom, :url)
        expect(resultat.first[:nom]).to eq('OPCO Financeur')
        expect(resultat.first[:url]).to eq('https://example.com')
        expect(resultat.first[:logo]).to be_present
      end
    end

    context 'quand la structure a un opco financeur' do
      let(:compte) { create(:compte) }
      let(:opco_financeur) { create(:opco, financeur: true, nom: 'OPCO Financeur', url: 'https://example.com') }
      let(:logo_file) { Rack::Test::UploadedFile.new(Rails.root.join('spec', 'support', 'programme_tele.png'), 'image/png') }

      before do
        compte.structure.update!(opco: opco_financeur)
        opco_financeur.logo.attach(logo_file)
      end

      it 'retourne l\'opco financeur' do
        resultat = helper.partenaires_opcos_financeurs(compte)

        expect(resultat.length).to eq(1)
        expect(resultat.first[:nom]).to eq('OPCO Financeur')
      end
    end
  end
end
