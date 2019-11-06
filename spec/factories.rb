FactoryBot.define do
    factory :user do
      email { 'test@ex.com' }
      username {'ex'}
      password { 'marvel99' }
      # using dynamic attributes over static attributes in FactoryBot
  
      # if needed
      # is_active true
    end
  end