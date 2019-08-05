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
    recived_sended = filter("friends").flatten!
    has_recived_sended = recived_sended != []
  end

  def pending
    pending = self.inverse_friendships.select{|friendship| 
      friendship if friendship.status == "waiting"
    }.map{|person| person}
    return pending
  end

  #Returns every frienship relation between the current user and the friend users
  
  def filter(status)
    recived_friends = self.inverse_friendships.select{|friendship| friendship if friendship.status == status}.map{|person| person}
    sended_friends = self.friendships.select{|friendship| friendship if friendship.status == status}.map{|person| person}
    frienships = []
    friendships << recived_friends
    frienships << sended_friends
    return frienships
  end
 
  
end
