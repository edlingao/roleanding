class PostsController < ApplicationController
    def create
        user = current_user
        post = user.posts.new post_params
        
        if post.save
            flash[:alert] = "post succesfully created"
            redirect_to root_path
        else
            flash[:alert] = "Something went wrong on creating your post"
            redirect_to root_path
        end
    end
    def edit
    end
    def update
    end
    def destroy
        post = Post.find(params[:id])
        if post.destroy
            flash[:alert] = "Post was succesfully deleted"
            redirect_to root_path
        else
            flash[:alert] = "Something went wrong on deleting your post"
            redirect_to root_path
        end
    end

    private
    def post_params
        params.require(:post).permit(:content)
    end
end
