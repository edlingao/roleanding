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


  #Returns true if the user has at least one friends relation
  def has_friends?
    recived_sended = filter("friends")
    return false if recived_sended.nil?
    true
  end


  #Returns an array with the friennndships with status = "friends"
  #ex: 
  #   [
  #     [array of recived friendships],
  #     [array of sended friendships]
  #   ]   

  def filter_friends
    friends = filter("friends")
    
  end

  #returns an array containing the friendship and the user
  # ex:
  #     [
  #       [user_1, friendship_user1_current_user],
  #       [user_2, friendship_user2_current_user]
  #     ]
  def blocked
    blockeds = Friendship.where status: "blocked", blocker: self.id
  end
  
  #returns the inverse_friendships with status = "waiting"
  #Or returns every frienship to confirm

  def pending
    pending = Friendship.where status: 'waiting', friend_id: self.id
    return pending
  end

  #Returns every frienship relation between the current user and the friend users by the status sended
  # [  
  #   [Array of recived friendships]
  #   [Array of sended friendships]
  # ]
  
  def filter(status)

    friendship = []
    friendship << Friendship.where(status: status, friend_id: self.id)
    friendship << Friendship.where(status: status, user_id: self.id)
    return friendship if friendship != [[],[]] 
    nil
  end
 
  
end
=begin
    recived_friends = self.inverse_friendships.where status: status
    sended_friends = self.friendships.where status: status
    friendships = Array.new
    friendships << recived_friends
    friendships << sended_friends
    return friendships
=end