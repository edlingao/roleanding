class FriendshipsController < ApplicationController
    def create
        @friendship = current_user.friendships.build(friend_id: params[:friend_id])
        @friendship.status = "waiting"

        if @friendship.save
            flash[:notice] = "Added friend."
            redirect_to root_path
        else
            flash[:alert] = "Unable to add friend."
            redirect_to root_path
        end
    end
    #"Accept" or 'Block' a user friendship status
    def update
        @friendship = find_friendship
        @friendship.status = params[:status]
        #Checks if the current user has blocked a friend
        if @friendship.status == "blocked"
            @friendship.blocker = params[:blocker]
        end
        if @friendship.save
            flash[:notice] = "Added friend." if @friendship.status != "blocked"
            flash[:notice] = "Blocked user" if @friendship.status == "blocked"
            redirect_to root_path
        else
            flash[:alert] = "Unable to add friend."
            redirect_to root_path
        end
    end
    #deletes a friendhsip relation
    def destroy
        @friendship = find_friendship
        @friendship.destroy
        flash[:notice] = "Removed friendship."
        redirect_to root_path
    end
    private
    #Looks for a friendship
    def find_friendship
        
        begin
            @friendship = current_user.inverse_friendships.find(params[:id]) 
        rescue ActiveRecord::RecordNotFound
            @friendship = current_user.friendships.find(params[:id]) 
        end

        return @friendship
    end
end
