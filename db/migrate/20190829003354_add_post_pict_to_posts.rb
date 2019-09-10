class AddPostPictToPosts < ActiveRecord::Migration[5.2]
  def change
    add_attachment :posts, :post_pic
  end
end
