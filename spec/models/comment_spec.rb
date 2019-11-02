require 'rails_helper'

RSpec.describe Comment, type: :model do
  context  "On creating comments" do
    before(:all) do
      @user = User.new(username: 'example', email: 'example@user.com',
      password: 'test123', password_confirmation: 'test123')
      
      @post = @user.posts.new content: 'example content'
      @comment = @post.comments.new user_id: @user.id

    end
    it "Belongs to a user" do 
      expect(@comment.user_id).to eql(@user.id)
    end

    it "Belongs to a post" do
      expect(@comment.post_id).to eql(@post.id)
    end
  end
end
