# frozen_string_literal: true

require 'rails_helper'

describe ApplicationHelper do
  describe '#formate_efficience' do
    it 'retourne le pourcentage arrondi' do
      expect(helper.formate_efficience(5.3)).to eql('5%')
    end

    it 'retourne la chaine indéterminé traduite' do
      expect(helper.formate_efficience(::Competence::NIVEAU_INDETERMINE))
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
      expect(helper.formate_duree(24 * 60 * 60 + 3661)).to eql('25:01:01')
    end

    it 'même si la durée est un décimal' do
      expect(helper.formate_duree(88_928.781648)).to eql('24:42:08')
      expect(helper.formate_duree(276.439082)).to eql('04:36')
    end

    it 'retourne nil si le paramètre est vide' do
      expect(helper.formate_duree('')).to eql(nil)
    end
  end

  describe '#public_static_url_pour' do
    let(:resource) { double }

    context "si la variable d'env est définie" do
      before { ENV['HOTE_STOCKAGE'] = 'host' }

      it "retourne l'url static, avec nom de fichier pour que l'app puis precharger la ressource" do
        expect(resource).to receive(:blob)
          .and_return({ 'key' => 'unique_blob_id', 'filename' => 'blob.jpg' })

        expect(helper.public_static_url_pour(resource))
          .to eql('http://host/unique_blob_id?filename=blob.jpg')
      end
    end

    context "si la variable d'env n'est pas définie (developpement)" do
      let(:routes) { double }
      let(:url_helpers) { double }

      before { ENV.delete('HOTE_STOCKAGE') }

      it 'retourne une url rails' do
        expect(Rails.application).to receive(:routes).and_return(routes)
        expect(routes).to receive(:url_helpers).and_return(url_helpers)
        expect(url_helpers).to receive(:url_for)
        helper.public_static_url_pour(resource)
      end
    end
  end
end
