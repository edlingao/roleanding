# frozen_string_literal: true

require 'rails_helper'



RSpec.describe Like, type: :model do
  before(:all) do
    @user = User.new(username: 'example', email: 'example@user.com',
    password: 'test123', password_confirmation: 'test123')
    
    @post = @user.posts.new content: 'example content'
    @like = @post.likes.new user_id: @user.id
  end
  context "On liking a post" do
    
    it "Belongs to one post" do

      expect(@like.post_id).to eql(@post.id)
        
    end
    it "Like belongs to one user" do
      expect(@like.user_id).to eql(@user.id)
    end
  end
end
