# frozen_string_literal: true

require 'rails_helper'

describe Structure, type: :integration do
  describe 'scopes' do
    describe '.sans_campagne' do
      let!(:structure) { create :structure_locale }
      context 'sans aucune campagne' do
        it { expect(Structure.sans_campagne.count).to eq 1 }
      end

      context 'avec au moins une campagne' do
        before do
          compte = create :compte, structure: structure
          create :campagne, compte: compte
        end
        it { expect(Structure.sans_campagne.count).to eq 0 }
      end
    end

    describe '.pas_vraiment_utilisatrices' do
      let!(:structure_pas_utilisatrice) { create :structure_locale }
      let!(:structure_utilisatrice) { create :structure_locale }

      before { cree_evaluations_pour_structure(structure_utilisatrice) }

      it { expect(Structure.pas_vraiment_utilisatrices).to include structure_pas_utilisatrice }
      it { expect(Structure.pas_vraiment_utilisatrices).not_to include structure_utilisatrice }
    end

    describe '.non_activees' do
      let!(:structure_non_activee) { create :structure_locale }
      let!(:structure_activee) { create :structure_locale }

      before do
        cree_evaluations_pour_structure structure_non_activee, nombre_evaluations: 3
        cree_evaluations_pour_structure structure_activee, nombre_evaluations: 4
      end

      it { expect(Structure.non_activees).to include structure_non_activee }
      it { expect(Structure.non_activees).not_to include structure_activee }
    end

    describe '.activees' do
      let!(:structure_activee) { create :structure_locale }

      before do
        cree_evaluations_pour_structure structure_activee, nombre_evaluations: 4
      end

      it { expect(Structure.activees).to include structure_activee }
    end

    describe '.inactives' do
      let!(:structure_activee) { create :structure_locale }
      let!(:structure_inactivee) { create :structure_locale }

      before do
        cree_evaluations_pour_structure(
          structure_activee,
          nombre_evaluations: 4,
          created_at: 2.month.ago + 1.day
        )
        cree_evaluations_pour_structure(
          structure_inactivee,
          nombre_evaluations: 4,
          created_at: 2.months.ago
        )
      end

      it { expect(Structure.inactives).to include structure_inactivee }
      it { expect(Structure.inactives).not_to include structure_activee }
    end

    describe '.abandonnistes' do
      let!(:structure_abandonnee) { create :structure_locale }

      before do
        cree_evaluations_pour_structure(
          structure_abandonnee,
          nombre_evaluations: 4,
          created_at: 6.months.ago
        )
      end

      it { expect(Structure.abandonnistes).to include structure_abandonnee }
    end

    describe '.avec_nombre_evaluations_et_date_derniere_evaluation' do
      let(:date_creation) { Time.new(2021, 8, 24) }
      let!(:structure_sans_evaluation) { create :structure_locale }
      let!(:structure_avec_evaluation) do
        structure = create :structure
        cree_evaluations_pour_structure(
          structure,
          created_at: date_creation
        )
        structure
      end

      let(:structures) do
        Structure.avec_nombre_evaluations_et_date_derniere_evaluation
                 .order(:created_at)
      end

      it do
        structure_avec_evaluation = structures.last
        expect(structure_avec_evaluation.nombre_evaluations).to eq 1
        expect(structure_avec_evaluation.date_derniere_evaluation).to eq date_creation
      end

      it { expect(structures).to include structure_sans_evaluation }
    end
  end

  def cree_evaluations_pour_structure(structure, nombre_evaluations: 1, **args_evaluations)
    compte = create :compte, structure: structure
    campagne = create :campagne, compte: compte

    options = { campagne: campagne }.merge(args_evaluations)
    create_list :evaluation, nombre_evaluations, options
  end
end
