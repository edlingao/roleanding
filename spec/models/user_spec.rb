require 'rails_helper'

RSpec.describe User, type: :model do
  before(:all) do
    @user = FactoryBot.create(:user)
    @friend = FactoryBot.create(:friend)
    @friendship = @user.friendships.new friend_id: @friend.id
    @friendship.status = 'waiting'
    @friendship.save
  end
  it "must have one friend" do
    
    expect(@friend.pending[0].id).to eql(@user.id) 
  end
  it "must accept a friendship" do
    @friendship.status = "friends"
    @friendship.save

    expect(@user.has_friends?).to eql(true)
  end
  it "must delete a friendship" do
    @friendship.destroy
    expect(@user.has_friends?).to eql(false)
  end
  
end
