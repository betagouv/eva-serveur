# frozen_string_literal: true

require 'rails_helper'

describe ApplicationHelper do
  describe '#formate_efficience' do
    it 'retourne le pourcentage arrondi' do
      expect(helper.formate_efficience(5.3)).to eql('5%')
    end

    it 'retourne la chaine indéterminé traduite' do
      expect(helper.formate_efficience(::Competence::NIVEAU_INDETERMINE))
        .to eql(I18n.t('admin.evaluations.evaluation.indetermine'))
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
end
