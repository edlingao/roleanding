# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Friendship, type: :model do
  context 'Sending a friendship request it most ' do
    before(:all) do
      @user = User.new(username: 'example', email: 'example@user.com',
                       password: 'test123', password_confirmation: 'test123')
      @friend = User.new(username: 'friend', email: "friend@friend.com",
                         password: "123456", password_confirmation: '123456')

      @friendship = @user.friendships.new friend_id: @friend, status: 'waiting'
      

    end
    it ', be part of the user' do
      expect(@friendship.user_id).to eql(@user.id)
    end
    it ', be part of the friend' do 
      expect(@friendship.friend_id).to eql(@friend.id)
    end
    it ', have status "waiting"' do
      expect(@friendship.status).to eql("waiting")
    end
    it ', have status "friends"' do
        @friendship.status = 'friends'
        expect(@friendship.status).to eql('friends')
    end
    it ', have status "blocked"' do
        @friendship.status = 'blocked'
        expect(@friendship.status).to eql('blocked')
    end
  end
end