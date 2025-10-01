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
end
