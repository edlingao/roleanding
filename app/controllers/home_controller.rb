class HomeController < ApplicationController
  
  def index
    @user = current_user
    @user ||= User.new username: "GUEST", email: "GUEST@GUEST.com", password: "GUEST1"
    @friends = @user.friends
    
  end
end
