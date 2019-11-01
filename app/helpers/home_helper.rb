# frozen_string_literal: true

module HomeHelper
  def resource_name
    :user
  end

  def resource_class
    User
  end

  def resource
    @resource ||= User.new
  end

  def devise_mapping
    @devise_mapping ||= Devise.mappings[:user]
  end

  def already_liked?(post_id)
    Like.where(user_id: current_user.id,
               post_id: post_id).exists?
  end
end
