# frozen_string_literal: true

class LikesController < ApplicationController
  def create
    @post = Post.find(params[:post_id])
    @like = @post.likes.new user_id: current_user.id
    respond_to do |format|
      if !already_liked?(@post.id)
        if @like.save
          format.html do
            flash['alert'] = 'Liked!'; redirect_to post_path(@post.id)
          end
        else
          format.html do
            falsh['alert'] = 'Cant like twice'; redirect_to root_path
          end
        end
      else
        format.html do
          flash['alert'] = 'Already liked!'; redirect_to post_path(@post.id)
        end
      end
      format.js
    end
  end

  def destroy
    @like = Like.find(params[:like_id])
    @post = @like.post
    respond_to do |format|
      format.js if @like.destroy
    end
  end

  private

  def already_liked?(post_id)
    Like.where(user_id: current_user.id,
               post_id: post_id).exists?
  end
end
