# frozen_string_literal: true

require 'rails_helper'

describe 'user visits home page', type: :feature do
  it ', succesfully' do
    visit root_path
    expect(page).to have_css '.login'
  end

  it 'and logs in' do
    login_as(FactoryBot.create(:user))
    visit root_path
    expect(page).to have_css 'img', class: 'profile-pic'
  end
end
