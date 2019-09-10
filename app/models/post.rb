class Post < ApplicationRecord
    belongs_to :user
    has_many :comments, dependent: :destroy
    has_attached_file :post_pic,
                      :storage => :cloudinary,
                      :path => ':id/:style/:filename',
                      :cloudinary_credentials => Rails.root.join("config/cloudinary.yml")

    validates_attachment_content_type :post_pic, content_type: /\Aimage\/.*\z/

end
