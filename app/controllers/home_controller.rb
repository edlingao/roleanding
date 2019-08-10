class HomeController < ApplicationController
  
  def index
    
    if user_signed_in?
      @user = current_user
      @friends = @user.filter_friends
      @pending = @user.pending
      @blocked = @user.blocked
      #@users = User.all
    end
  end
end
