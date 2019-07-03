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

  describe '#progression_efficience' do
    it 'retourne la valeur' do
      expect(helper.progression_efficience(5.3)).to eql(5.3)
    end

    it "retourne 0 si l'efficience est indéterminée" do
      expect(helper.progression_efficience(::Competence::NIVEAU_INDETERMINE)).to eql(0)
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
  end
end
