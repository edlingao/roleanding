# frozen_string_literal: true

class FriendshipsController < ApplicationController
  def create
    @friendship = current_user.friendships.build(friend_id: params[:friend_id])
    @friendship.status = 'waiting' unless params[:blocked]
    @friendship.status ||= 'blocked'
    @friendship.blocker = current_user.id if @friendship.status == 'blocked'
    @user = @friendship.friend
    respond_to do |format|
      if @friendship.save
        format.html do
          flash[:notice] = 'Succes'
          redirect_to search_path
        end
        format.js

      else
        format.html do
          flash[:alert] = 'Something went wrong'
          redirect_to search_path
        end

      end
    end
  end

  # "Accept" or 'Block' a user friendship status
  def update
    @friendship = find_friendship
    @user = @friendship.friend if @friendship.friend != current_user
    @user ||= @friendship.user

    @friendship.status = params[:status]
    # Checks if the current user has blocked a friend
    @friendship.blocker = current_user.id if @friendship.status == 'blocked'
    respond_to do |format|
      if @friendship.save
        format.html do
          flash[:notice] = 'Added friend.' if @friendship.status != 'blocked'
          flash[:notice] = 'Blocked user' if @friendship.status == 'blocked'
          redirect_to search_path if params[:from] == 'search'
          redirect_to notifications_path unless params[:from]
        end

      else
        format.html do
          flash[:alert] = 'Unable to add friend.'
          redirect_to notifications_path
        end

      end
      format.js
    end
  end

  # deletes a friendhsip relation
  def destroy
    @friendship = find_friendship
    @user = @friendship.friend unless @friendship.friend.username == current_user.username
    @user ||= @friendship.user
    @friendship.destroy

    respond_to do |format|
      format.html do
        flash[:notice] = 'Removed friendship.'
        redirect_to search_path
      end
      format.js
    end
  end

  private

  # Looks for a friendship
  def find_friendship
    begin
      @friendship = current_user.inverse_friendships.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      @friendship = current_user.friendships.find(params[:id])
    end

    @friendship
  end
end
