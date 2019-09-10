class SearchController < ApplicationController
    def index
        @user = current_user
        if params[:search]
            @people = @user.search(params[:search].downcase)
        else
            @people = @user.all_users
        end
        if params[:search] == "blockeds"
            @people = @user.blocked
        end
        if params[:search] == "friends"
            @people = @user.all_friends
        end
    end

    def show
        @user = current_user
        @people = @user.pending
    end
private
    def searhc_params
        param.require(:search).permit(:search)
    end
end
