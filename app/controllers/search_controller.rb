# frozen_string_literal: true

class SearchController < ApplicationController
  before_action :authenticate_user!
  def index
    @user = current_user
    @people = params[:search] ? @user.search(params[:search].downcase) : @user.all_users

    @people = @user.blocked if params[:search] == 'blockeds'
    @people = @user.all_friends if params[:search] == 'friends'
  end

  def show
    @user = current_user
    @people = @user.pending
  end

  private

  def search_params
    param.require(:search).permit(:search)
  end
end
