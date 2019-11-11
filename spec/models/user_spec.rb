# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  before(:all) do
    @user = FactoryBot.create(:user)
    @friend = FactoryBot.create(:friend)
    @friendship = @user.friendships.new friend_id: @friend.id
    @friendship.status = 'waiting'
    @friendship.save
  end
  it 'must have one friend' do
    expect(@friend.pending[0].id).to eql(@user.id)
  end
  it 'must accept a friendship' do
    @friendship.status = 'friends'
    @friendship.save

    expect(@user.has_friends?).to eql(true)
  end
  it 'checks if two users are friends' do
    expect(@user.are_we_friends?(@friend.id)).to eql(true)
  end
  it 'checks if the user blocked another user' do
    expect(@user.blocked?(@friend.id)).to eql(false)
  end
  it 'search a user by its username' do
    expect(@user.search(@friend.username)[0]).to eql(@friend)
  end
  it 'returns all users except the current user' do
    expect(@user.all_users[0]).to eql(@friend)
  end
  it 'returns all the users with status: friends' do
    expect(@user.all_users(true)[0]).to eql(@friend)
  end
  it 'must delete a friendship' do
    @friendship.destroy
    expect(@user.has_friends?).to eql(false)
  end
end
