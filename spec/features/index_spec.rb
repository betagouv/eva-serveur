# frozen_string_literal: true

require 'rails_helper'

describe 'Index', type: :feature do
  it 'Redirige vers activeadmin' do
    visit '/'
    expect(page.current_url).to eql('http://www.example.com/admin/login')
  end
end
