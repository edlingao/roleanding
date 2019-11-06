# frozen_string_literal: true

class LikesController < ApplicationController
  def create
    @post = Post.find(params[:post_id])
    @like = @post.likes.new user_id: current_user.id
    respond_to do |format|
      if !already_liked?(@post.id)
        if @like.save
          format.html{
            flash['alert'] = 'Liked!'
            redirect_to post_path(@post.id)
          }
          format.js
        else
          format.html{
            falsh['alert'] = 'Cant like twice'
            redirect_to root_path
          }
          format.js
        end

      else
        format.html{
          flash['alert'] = 'Already liked!'
          redirect_to post_path(@post.id)
        }
        format.js
      end
      
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
