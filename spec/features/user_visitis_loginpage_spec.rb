# frozen_string_literal: true

require 'rails_helper'

describe 'user visits home page', type: :feature do

  before(:each) do |test|

    @user = FactoryBot.create(:user) 
    login_as(@user) unless test.metadata[:logged_out]

  end
  it ', succesfully', :logged_out do
    visit root_path
    expect(page).to have_css '.login'
  end

  it 'and logs in' do
    visit root_path
    expect(page).to have_css 'div', class: 'post-form'
  end
  it 'and post something' do
  
    visit root_path
    fill_in 'new_post_text_area', with: 'test numero #1'
    click_on 'send_new_post'
    visit visit current_path

    expect(page).to have_css 'p', text: 'test numero #1'
  end
  it 'and likes a post', format: :js do
    
    visit root_path
    fill_in 'new_post_text_area', with: 'test numero #1'
    click_on 'send_new_post'
    visit current_path

    click_link class: 'like'
    visit current_path

    expect(page).to have_css 'a', class: 'dislike'
  end

  it 'and comments a post' do
    
    visit root_path
    fill_in 'new_post_text_area', with: 'test numero #1'
    click_on 'send_new_post'
    visit current_path

    fill_in class: 'new_comment', with: 'first comment'
    click_on 'submit_comment'
    visit current_path

    expect(page).to have_css 'p', text: 'first comment'
  end
  it "and sends a friend request" do
    friend = FactoryBot.create(:friend)
    visit search_path
    click_link class: 'add-person'
    visit current_path

    expect(page).to have_css 'a', class: 'waiting'
  end
  it "and accepts friend requests" do
    friend = FactoryBot.create(:friend)
    visit search_path
    click_link class: 'add-person'
    visit current_path

    logout(User)
    login_as(friend)
    visit notifications_path
    click_link class: 'accept-friendship'
    visit root_path

    expect(page).to have_css '.friend p', text: @user.username
  end
end
