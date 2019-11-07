# frozen_string_literal: true

class PostsController < ApplicationController
  def show
    @post = find_post
    @user = current_user
    @user ||= 'PUBLIC'
    @author = @post.user
    @comments = @post.comments
    @new_comment = @post.comments.new
  end

  def create
    @user = current_user
    @post = @user.posts.new post_params
    respond_to do |format|
      if @post.save
        format.html do
          flash[:alert] = 'post succesfully created'
          redirect_to post_path(@post.id)
        end
      else
        format.html do
          flash[:alert] = 'Something went wrong on creating your post'
          redirect_to root_path
        end
      end
      format.js
    end
  end

  def edit
    @post = find_post
    @new_post = find_post
    @author = current_user
    redirect_to root_path if @post.user_id != current_user.id
  end

  def update
    @post = find_post
    @post.update_attributes(post_params)
    if @post.save
      flash[:alert] = 'Post updated'
      redirect_to post_path(params[:id])
    else
      flash[:alert] = 'Something happend when updating your post'
      redirect_to root_path
    end
  end

  def destroy
    post = Post.find(params[:id])
    if post.destroy
      flash[:alert] = 'Post was succesfully deleted'
      redirect_to root_path
    else
      flash[:alert] = 'Something went wrong on deleting your post'
      redirect_to root_path
    end
  end

  private

  def find_post
    Post.find params[:id]
  end

  def post_params
    params.require(:post).permit(:content, :post_pic)
  end
end
