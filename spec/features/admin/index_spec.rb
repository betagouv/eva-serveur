# frozen_string_literal: true

require 'rails_helper'

describe 'Index', type: :feature do
  it 'Redirige vers activeadmin' do
    visit '/'
    expect(page.current_url).to eql(new_compte_session_url)
  end

  it 'Redirige vers la page 404' do
    visit '/page_inconnue'
    expect(page).to have_http_status(:not_found)
  end

  it 'Render page 404' do
    visit '/pro/404'
    expect(page).to have_content "La page demandée n'existe pas."
  end

  it 'Render page 500' do
    visit '/pro/500'
    expect(page).to have_content 'Une erreur est survenue'
  end

  it 'Render page 422' do
    visit '/pro/422'
    expect(page).to have_content 'Veuillez réessayer'
  end
end
