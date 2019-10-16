# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Post, type: :model do
  context "Post" do
    
    it "Creates a post that belongs to only one user" do
        @user = User.new(username: "example", email: "example@user.com", 
                          password: "test123", password_confirmation: "test123")
                          
        @post = @user.posts.new content: 'example content'
        expect(@post.valid?).to eql(true), "The post got to be created by a user"
    end
  end
end
