# frozen_string_literal: true

require 'rails_helper'

describe 'Admin - Evenement', type: :feature do
  let(:chemin) { "#{Rails.root}/spec/support/evenement/description.json" }
  let(:description) { JSON.parse(File.read(chemin)) }
  let!(:evenement) do
    create :evenement, type_evenement: 'ouvertureContenant',
                       description: description,
                       situation: 'inventaire',
                       session_id: '1898098HJk8902'
  end

  before(:each) { se_connecter_comme_administrateur }

  it 'Affiche les événements' do
    visit admin_evenements_path
    expect(page).to have_content 'ouvertureContenant'
    expect(page).to have_content description
    expect(page).to have_content 'inventaire'
    expect(page).to have_content '1898098HJk8902'
  end
end
