# frozen_string_literal: true

class SearchController < ApplicationController
  def index
    @user = current_user
    @people = if params[:search]
                @user.search(params[:search].downcase)
              else
                @user.all_users
              end
    @people = @user.blocked if params[:search] == 'blockeds'
    @people = @user.all_friends if params[:search] == 'friends'
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
