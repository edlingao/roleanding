# frozen_string_literal: true

class AddProfilePictToUsers < ActiveRecord::Migration[5.2]
  def change
    add_attachment :users, :profile_pic
  end
end
