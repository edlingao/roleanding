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
    expect(page).to have_css 'div', class: 'post-form'
  end
  it 'and post something' do
    user = FactoryBot.create(:user)
    login_as(user)
    visit root_path
    fill_in 'new_post_text_area', with: 'test numero #1'
    click_on 'send_new_post'
    visit visit current_path

    expect(page).to have_css 'p', text: 'test numero #1'
  end
  it 'and likes a post', format: :js do
    user = FactoryBot.create(:user)
    login_as(user)
    visit root_path
    fill_in 'new_post_text_area', with: 'test numero #1'
    click_on 'send_new_post'
    visit current_path

    click_link class: 'like'
    visit current_path

    expect(page).to have_css 'a', class: 'dislike'
  end

  it 'and comments a post' do
    user = FactoryBot.create(:user)
    login_as(user)
    visit root_path
    fill_in 'new_post_text_area', with: 'test numero #1'
    click_on 'send_new_post'
    visit current_path

    fill_in class: 'new_comment', with: 'first comment'
    click_on 'submit_comment'
    visit current_path

    expect(page).to have_css 'p', text: 'first comment'
  end
end
