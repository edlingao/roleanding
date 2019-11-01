class LikesController < ApplicationController

    def create
        @post = Post.find(params[:post_id])
        @like = @post.likes.new user_id: current_user.id 

        if not already_liked?(@post.id)
            if @like.save
                flash["alert"] = "Liked!"

                respond_to do |format|
                    format.js
                end
            else
                falsh["alert"] = "Cant like twice"
                redirect_to root_path
            end
            
        else
            flash["alert"] = "Already liked!"
            redirect_to post_path(@post.id)
        end
        respond_to do |format|
            format.js
        end
    end

    def destroy
        @like = Like.find(params[:like_id])
        @post = @like.post
        respond_to do |format|
            if @like.destroy
                format.js
            end
        end

    end
    
    private
    def already_liked?(post_id)
        Like.where(user_id: current_user.id, 
                post_id:post_id).exists?
    end
end
