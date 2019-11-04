# frozen_string_literal: true

module Features
  def sign_in
    visit root_path
    fill_in 'user_email', with: 'edwincosmos32@hotmail.com'
    fill_in 'user_password', with: 'marvel99'
    click_on 'sign_in'
    visit user_home_path('edlingao')
  end
end
