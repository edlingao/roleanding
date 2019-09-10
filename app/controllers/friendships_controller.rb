class FriendshipsController < ApplicationController
    def create
        @friendship = current_user.friendships.build(friend_id: params[:friend_id])
        @friendship.status = "waiting" if not params[:blocked]
        @friendship.status ||= "blocked"
        if @friendship.status == 'blocked'
            @friendship.blocker = current_user.id
        end
        if @friendship.save
            flash[:notice] = "Succes"
            redirect_to search_path
        else
            flash[:alert] = "Something went wrong"
            redirect_to search_path
        end
    end
    #"Accept" or 'Block' a user friendship status
    def update
        @friendship = find_friendship
        @friendship.status = params[:status]
        #Checks if the current user has blocked a friend
        if @friendship.status == "blocked"
            @friendship.blocker = current_user.id
        end
        if @friendship.save
            flash[:notice] = "Added friend." if @friendship.status != "blocked"
            flash[:notice] = "Blocked user" if @friendship.status == "blocked"
            redirect_to search_path if params[:from] == "search"
            redirect_to notifications_path if not params[:from]
        else
            flash[:alert] = "Unable to add friend."
            redirect_to notifications_path
        end
    end
    #deletes a friendhsip relation
    def destroy
        @friendship = find_friendship
        @friendship.destroy
        flash[:notice] = "Removed friendship."
        redirect_to search_path
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
