# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :authenticate_user!, only: %i[index update]
  def index
    @user = current_user
    @friends = @user.all_users true
    @posts = @user.posts.order('created_at DESC')
    @new_post = Post.new
  end

  def show
    @user = current_user
    @user ||= 'PUBLIC'
    @public_user = User.find_by(username: params[:username])
    if !@public_user.nil?
      if @user != 'PUBLIC'
        redirect_to '/404' if @user.blocked?(@public_user.id)
      end
      redirect_to user_home_path if @user == @public_user
      @posts = @public_user.posts.order('created_at DESC')
      @friends = @public_user.all_users(true)
    else
      redirect_to '/404'
    end
  end

  def update
    @user = current_user
    @user.update_attributes(user_params)
    redirect_to user_home_path(@user.username) if @user.save
  end

  private

  def user_params
    params.require(:user).permit(:profile_pic)
  end
end
