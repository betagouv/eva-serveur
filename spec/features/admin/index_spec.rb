# frozen_string_literal: true

require 'rails_helper'

describe 'Index', type: :feature do
  it 'Redirige vers activeadmin' do
    visit '/'
    expect(page.current_url).to eql(new_compte_session_url)
  end
end
