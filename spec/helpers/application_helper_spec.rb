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
end
