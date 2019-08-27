class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  before_save{email.downcase!}
  before_save{username.downcase!}
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  validates :username, presence: true, uniqueness: {case_sensitive: false},
                       length: {maximum: 30}

  has_many :friendships
  has_many :friends,  through: :friendships
  has_many :inverse_friendships, class_name: "Friendship", foreign_key: "friend_id"
  has_many :inverse_friends, through: :inverse_friendships, source: :user
  has_many :posts, dependent: :destroy
  has_many :comments, dependent: :destroy

  
  def all_users
    all_users = []
    sql = "SELECT u.id, u.username
           FROM users u 
           WHERE u.id != #{self.id} AND NOT EXISTS(SELECT friendships.id FROM friendships WHERE (friendships.user_id = #{self.id} AND friendships.friend_id = u.id) OR (friendships.friend_id = #{self.id} AND friendships.user_id = u.id))"
    unexisting_friendships = User.find_by_sql(sql)
    sql = "SELECT u.id, u.username, f.id AS friendship_id, f.status
           FROM users u JOIN friendships f ON (f.user_id = #{self.id} AND f.friend_id = u.id) OR (f.friend_id = #{self.id} AND f.user_id = u.id)
           WHERE u.id != #{self.id} AND EXISTS(SELECT friendships.id FROM friendships WHERE (friendships.user_id = #{self.id} AND friendships.friend_id = u.id) OR (friendships.friend_id = #{self.id} AND friendships.user_id = u.id))
           AND CASE
           WHEN f.status = 'blocked' AND f.blocker != #{self.id}
           THEN false
           ELSE true
           END
           "
    existing_friendships = User.find_by_sql(sql)
    all_users << unexisting_friendships
    all_users << existing_friendships
    all_users.flatten!
  end


  def relevant_posts
    sql = "SELECT u.id, u.username, p.id, p.content, p.created_at
    FROM users u 
    JOIN friendships f ON (f.user_id = #{self.id} AND f.friend_id = u.id) OR (f.friend_id = #{self.id} AND f.user_id = u.id)
    JOIN posts p ON p.user_id = u.id
    WHERE f.status = 'friends'
    ORDER BY p.created_at DESC"

    posts = Post.find_by_sql(sql)
   
  end
  def own_posts
    sql = "SELECT u.id, u.username, p.id, p.content, p.created_at
           FROM users u 
           JOIN posts p ON p.user_id = u.id
           WHERE u.id = #{self.id}
           ORDER BY p.created_at DESC"
    posts = Post.find_by_sql(sql)
  end

  #Returns our friend user_id and user name, also returns a friendship_id and the status Only where the status is 'friends' 
  def all_friends
    sql = "SELECT u.id, u.username, f.id AS friendship_id, f.status
           FROM users u JOIN friendships f ON (f.user_id = #{self.id} AND f.friend_id = u.id) OR (f.friend_id = #{self.id} AND f.user_id = u.id)
           WHERE u.id != #{self.id} AND f.status = 'friends'"  
    friends = User.find_by_sql(sql)
  end
  #Returns true if the user has at least one friendship with status = 'friends' 
  def has_friends?
    recived_sended = self.all_friends
    return false if recived_sended == []
    true
  end
  #returns every user that
  def blocked
    sql = "SELECT u.id, u.username, f.id AS friendship_id, f.status
           FROM users u JOIN friendships f ON (f.user_id = #{self.id} AND f.friend_id = u.id) OR (f.friend_id = #{self.id} AND f.user_id = u.id)
           WHERE u.id != #{self.id} AND f.status = 'blocked' AND f.blocker = #{self.id}"  
    blocked = User.find_by_sql(sql)
  end
  
  #returns the inverse_friendships with status = "waiting"
  #Or returns every frienship to confirm

  def pending
    pending = Friendship.where(status: 'waiting', friend_id: self.id)
    return pending
  end


end