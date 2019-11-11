# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Post, type: :model do
  before(:all) do
    @user = FactoryBot.create(:user)
    @friend = FactoryBot.create(:friend)
  end
  context 'user' do
    @user.has
  end
end
