require 'rails_helper'

class TestRecord < StaticRecord::Base
  attr_reader :nom_technique, :score, :metacompetence

  def initialize(attributes = {})
    super()
    @nom_technique = attributes['nom_technique']
    @score = attributes['score']
    @metacompetence = attributes['metacompetence']
  end
end

describe StaticRecord::Base, type: :model do
  before do
    TestRecord.chemin_data = 'test/*.yml'
    allow(Dir).to receive(:glob).and_return([ '/path/to/test_file.yml' ])
  end

  describe '.all' do
    let(:yml_data) do
      [
        { 'nom_technique' => 'test_1', 'score' => 1, 'metacompetence' => 'comprehension' },
        { 'nom_technique' => 'test_2', 'score' => 2, 'metacompetence' => 'production' }
      ]
    end

    before do
      allow(YAML).to receive(:load_file).and_return(yml_data)
    end

    it 'charge tous les enregistrements et renvoie un tableau d\'instances' do
      records = TestRecord.all

      expect(records).to be_an(Array)
      expect(records.size).to eq(yml_data.size)
      expect(records.first).to be_a(TestRecord)
      expect(records.map(&:nom_technique)).to contain_exactly('test_1', 'test_2')
    end
  end

  describe '.where' do
    let(:yml_data) do
      [
        { 'nom_technique' => 'test_1', 'score' => 1, 'metacompetence' => 'comprehension' },
        { 'nom_technique' => 'test_2', 'score' => 2, 'metacompetence' => 'production' },
        { 'nom_technique' => 'test_3', 'score' => 1, 'metacompetence' => 'comprehension' }
      ]
    end

    before do
      allow(YAML).to receive(:load_file).and_return(yml_data)
    end

    it 'renvoie les instances correctes qui repondent a la condition' do
      result = TestRecord.where(score: 1)

      expect(result.size).to eq(2)
      expect(result.map(&:nom_technique)).to contain_exactly('test_1', 'test_3')
    end
  end

  describe '.find_by' do
    let(:yml_data) do
      [
        { 'nom_technique' => 'test_1', 'score' => 1, 'metacompetence' => 'comprehension' },
        { 'nom_technique' => 'test_2', 'score' => 2, 'metacompetence' => 'production' }
      ]
    end

    before do
      allow(YAML).to receive(:load_file).and_return(yml_data)
    end

    it 'renvoie la premiere instance qui correspond aux conditions donnees' do
      result = TestRecord.find_by(metacompetence: 'production')

      expect(result).to be_a(TestRecord)
      expect(result.nom_technique).to eq('test_2')
    end

    it 'renvoie nil lorsqu\'aucune instance ne correspond aux conditions' do
      result = TestRecord.find_by(score: 3)

      expect(result).to be_nil
    end
  end
end
