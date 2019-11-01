# frozen_string_literal: true

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  before_save { email.downcase! }
  before_save { username.downcase! }
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  devise :omniauthable, omniauth_providers: [:facebook]

  validates :username, presence: true, uniqueness: { case_sensitive: false },
                       length: { maximum: 30 }

  has_many :friendships, dependent: :destroy
  has_many :friends, through: :friendships
  has_many :inverse_friendships, class_name: 'Friendship', foreign_key: 'friend_id', dependent: :destroy
  has_many :inverse_friends, through: :inverse_friendships, source: :user
  has_many :posts, dependent: :destroy
  has_many :comments, dependent: :destroy

  has_many :likes, dependent: :destroy

  has_attached_file :profile_pic,
                    storage: :cloudinary,
                    path: 'roleanding/users/:id/:username/:style/:filename',
                    cloudinary_credentials: Rails.root.join('config/cloudinary.yml')

  validates_attachment_content_type :profile_pic, content_type: %r{\Aimage/.*\z}

  def self.new_with_session(params, session)
    super.tap do |user|
      if data = session['devise.facebook_data'] && session['devise.facebook_data']['extra']['raw_info']
        user.email = data['email'] if user.email.blank?
      end
    end
  end

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
      user.password = Devise.friendly_token[0, 20]
      user.name = auth.info.name # assuming the user model has a name
      user.profile_pic_file_name = auth.info.image # assuming the user model has an image
    end
  end

  def are_we_friends?(other_user_id)
    sql = "SELECT u.id, u.username,u.profile_pic_file_name, f.id AS friendship_id, f.status
           FROM users u
           JOIN friendships f ON (f.user_id = #{id} AND f.friend_id = #{other_user_id}) OR (f.friend_id = #{id} AND f.user_id = #{other_user_id})
           WHERE u.id != #{id} AND f.status = 'friends'"
    friends = User.find_by_sql(sql)
    return true if friends != [] || other_user_id == id

    false
  end

  def blocked?(other_user_id)
    blocked = self.blocked.any? { |blocked_person| blocked_person.id == other_user_id }
    block_by = blocked_me.any? { |blocked_from| blocked_from.id == other_user_id }
    (blocked = blocked) || block_by
  end

  def all_users
    all_users = []
    sql = "SELECT u.id, u.username, u.profile_pic_file_name
           FROM users u
           WHERE u.id != #{id} AND NOT EXISTS(SELECT friendships.id FROM friendships WHERE (friendships.user_id = #{id} AND friendships.friend_id = u.id) OR (friendships.friend_id = #{id} AND friendships.user_id = u.id))"
    unexisting_friendships = User.find_by_sql(sql)
    sql = "SELECT u.id, u.username, u.profile_pic_file_name, f.id AS friendship_id, f.status
           FROM users u JOIN friendships f ON (f.user_id = #{id} AND f.friend_id = u.id) OR (f.friend_id = #{id} AND f.user_id = u.id)
           WHERE u.id != #{id} AND EXISTS(SELECT friendships.id FROM friendships WHERE (friendships.user_id = #{id} AND friendships.friend_id = u.id) OR (friendships.friend_id = #{id} AND friendships.user_id = u.id))
           AND CASE
           WHEN f.status = 'blocked' AND f.blocker != #{id}
           THEN false
           ELSE true
           END
           "
    existing_friendships = User.find_by_sql(sql)
    all_users << unexisting_friendships
    all_users << existing_friendships
    all_users.flatten!
  end

  def search(username)
    all_users = []
    sql = "SELECT u.id, u.username, u.profile_pic_file_name
           FROM users u
           WHERE u.id != #{id} AND u.username LIKE '#{username}%' AND NOT EXISTS(SELECT friendships.id FROM friendships WHERE (friendships.user_id = #{id} AND friendships.friend_id = u.id) OR (friendships.friend_id = #{id} AND friendships.user_id = u.id))"
    unexisting_friendships = User.find_by_sql(sql)
    sql = "SELECT u.id, u.username,u.profile_pic_file_name, f.id AS friendship_id, f.status
           FROM users u JOIN friendships f ON (f.user_id = #{id} AND f.friend_id = u.id) OR (f.friend_id = #{id} AND f.user_id = u.id)
           WHERE u.id != #{id} AND u.username LIKE '#{username}%' AND EXISTS(SELECT friendships.id FROM friendships WHERE (friendships.user_id = #{id} AND friendships.friend_id = u.id) OR (friendships.friend_id = #{id} AND friendships.user_id = u.id))
           AND CASE
           WHEN f.status = 'blocked' AND f.blocker != #{id}
           THEN false
           ELSE true
           END"
    existing_friendships = User.find_by_sql(sql)
    all_users << unexisting_friendships
    all_users << existing_friendships
    all_users.flatten!
  end

  def relevant_posts
    sql = "SELECT u.id AS user_id, u.username,
                  p.id, p.content, p.created_at, p.post_pic_file_name
           FROM users u
           JOIN friendships f ON (f.user_id = #{id} AND f.friend_id = u.id) OR (f.friend_id = #{id} AND f.user_id = u.id)
           JOIN posts p ON p.user_id = u.id
           WHERE f.status = 'friends'
           ORDER BY p.created_at DESC"

    posts = Post.find_by_sql(sql)
  end

  # Returns our friend user_id and user name, also returns a friendship_id and the status Only where the status is 'friends'
  def all_friends
    sql = "SELECT u.id, u.username,u.profile_pic_file_name, f.id AS friendship_id, f.status
           FROM users u
           JOIN friendships f ON (f.user_id = #{id} AND f.friend_id = u.id) OR (f.friend_id = #{id} AND f.user_id = u.id)
           WHERE u.id != #{id} AND f.status = 'friends'"
    friends = User.find_by_sql(sql)
  end

  # Returns true if the user has at least one friendship with status = 'friends'
  def has_friends?
    recived_sended = all_friends
    return false if recived_sended == []

    true
  end

  def blocked_me
    sql = "SELECT u.id, u.username, f.id AS friendship_id, f.status
           FROM users u JOIN friendships f ON (f.user_id = #{id} AND f.friend_id = u.id) OR (f.friend_id = #{id} AND f.user_id = u.id)
           WHERE u.id != #{id} AND f.status = 'blocked' AND f.blocker != #{id}"
    blocked = User.find_by_sql(sql)
  end

  # returns every user that
  def blocked
    sql = "SELECT u.id, u.username, u.profile_pic_file_name, f.id AS friendship_id, f.status
           FROM users u JOIN friendships f ON (f.user_id = #{id} AND f.friend_id = u.id) OR (f.friend_id = #{id} AND f.user_id = u.id)
           WHERE u.id != #{id} AND f.status = 'blocked' AND f.blocker = #{id}"
    blocked = User.find_by_sql(sql)
  end

  # returns the inverse_friendships with status = "waiting"
  # Or returns every frienship to confirm

  def pending
    sql = "SELECT u.id, u.username,u.profile_pic_file_name, f.id AS friendship_id, f.status
           FROM users u
           JOIN friendships f ON (f.friend_id = #{id} AND f.user_id = u.id)
           WHERE u.id != #{id} AND f.status = 'waiting'"
    pending = User.find_by_sql(sql)
    pending
  end
end
