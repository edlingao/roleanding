class CommentsController < ApplicationController
    def create
        comment = current_user.comments.build comment_params
        if comment.save
            flash["alert"] = "Success on commenting"
            redirect_to post_path(comment.post.id)
        else
            flash["alert"] = "Something went wrong, try again later"
            redirect_to root_path
        end
        
    end

    def edit

    end

    def update
    
    end

    def destroy
        comment = Comment.find(params[:id])
        if comment.destroy
            flash["alert"] = 'comment deleted'
            redirect_to root_path
        else
            flash['alert'] = 'Something went wrong on deleting this comment'
            redirect_to root_path
        end
    end

    private

    def comment_params
        params.require(:comment).permit(:content,:post_id)
    end
end
