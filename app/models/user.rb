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


  
  def all_users
    all_users = User.all
    users = []
    all_users.each{|user|
      if user.id == self.id && Friendship.exists?(user_id: user.id) || Friendship.exists?(friend_id: user.id)
        users << user
      end
    }

    users
  end

  def test 
    friends = User.joins(:friendships).where(friendships.user_id: )
  end
  #Returns true if the user has at least one friends relation
  def has_friends?
    recived_sended = filter("friends")
    return false if recived_sended == [nil]
    true
  end

=begin
  Returns an array with the friennndships with status = "friends" if there are no friends it returns nil
  ex: 
    [
      Array of recived friendships
      [
        Array with the user and the freindship
        [User, Friendship],
        [User, Friendship]
      ],
  
      Array of sended friendships
      [ 
        Array with the user and the freindship
        [User, Friendship],
        [User, Friendship]
      ]
  
    ]   
=end
  def filter_friends
    if self.has_friends?
      friendships = filter("friends")
      recived = []
      temp = []
      sended =[]
      friends = []
      friendships.each {|array_of_sended_or_recived|

        array_of_sended_or_recived.each{|friendship|
          if friendship.user_id != self.id
            temp << User.find(friendship.user_id)
            temp << friendship

            recived << temp
          else
            temp << User.find(friendship.friend_id)
            temp << friendship
            sended << temp
          end
          temp = []
        }

      }
      friends << recived
      friends << sended
      return friends
    else
      return [nil]
    end
    
  end
=begin
  Returns an array containing the friendship and the user with the blocked information
  ex:
      [
        Recived Friendships array
        [user, friendship],
        [user, friendship]
      [
      ],
        Sended Friendships array
        [user, friendship],
        [user, friendship]
      ]
=end
  def blocked
    temp = []
    recived_fs = []
    sended_fs =[]
    blockeds = []
    
    blockeds_fs = Friendship.where status: "blocked", blocker: self.id
    blockeds_fs.each {|friendship|
      if friendship.user_id != self.id
        temp << User.find(friendship.user_id)
        temp << friendship

        recived_fs << temp
      else
        temp << User.find(friendship.friend_id)
        temp << friendship
        sended_fs << temp
      end
      temp = []
    }
    blockeds << recived_fs
    blockeds << sended_fs
    return blockeds
  end
  
  #returns the inverse_friendships with status = "waiting"
  #Or returns every frienship to confirm

  def pending
    pending = Friendship.where status: 'waiting', friend_id: self.id
    return pending
  end
=begin
  Returns every frienship relation between the current user and the friend users by the status sended
  [  
    [Array of recived friendships]
    [Array of sended friendships]
  ]
=end
  def filter(status)

    friendship = []
    friendship << Friendship.where(status: status, friend_id: self.id)
    friendship << Friendship.where(status: status, user_id: self.id)
    return friendship if friendship != [[],[]] 
    [nil]
  end
 
end
