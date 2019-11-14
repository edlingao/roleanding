# frozen_string_literal: true

class HomeController < ApplicationController
  def index
    if user_signed_in?
      @user = current_user
      @friends = @user.all_users true
      @pending = @user.pending
      @blocked = @user.blocked
      @posts = @user.relevant_posts
      @new_post = Post.new
    end
  end
end
