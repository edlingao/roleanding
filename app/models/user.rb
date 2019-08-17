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
      if user.id == self.id && !Friendship.exists?(user_id: user.id) || !Friendship.exists?(friend_id: user.id)
        users << user
      end
    }

    users
  end

  def test 
    #users.id != #{self.id} AND
    # AND friendships.blocker != #{self.id}
    #, (SELECT friendships.id FROM friendships WHERE users.id != #{self.id} AND (users.id = friendships.user_id OR users.id = friendships.friend_id)) AS friendship_id 

    sql = "SELECT users.id, users.username
           FROM users 
           WHERE users.id != #{self.id} AND 
           
           CASE
            WHEN NOT EXISTS(SELECT friendships.id FROM friendships
                            WHERE users.id = friendships.user_id OR users.id = friendships.friend_id)
            THEN
              true
            ELSE
              CASE 
                WHERE EXISTS(SELECT friendships.id FROM friendships 
                  WHERE (users.id = friendships.user_id OR users.id = friendships.friend_id)
                  AND
                  CASE
                    WHEN friendships.status = 'blocked' AND friendships.blocker = #{self.id}
                    THEN true
                    WHEN friendships.friend_id != #{self.id} AND friendships.user_id != #{self.id}
                    THEN true
                    ELSE false
                  END
                )
                THEN true  
                ELSE false
              END
           END;"
    #sql = "SELECT username FROM users"
    temp = []
    temp << User.find_by_sql(sql)
    #temp << User.select("users.* FROM users JOIN friendships ON users.id = friendships.user_id").where("friendships.status = 'friends' AND users.id != ?", self.id)
    #temp << User.select("users.*, friendships.* FROM users JOIN friendships ON users.id = friendships.friend_id").where("friendships.status = 'friends' AND users.id != ?", self.id)

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


=begin 

SELECT users.id, users.username, (SELECT friendships.id FROM friendships WHERE users.id = friendships.user_id or users.id = friendships.friend_id) AS friendship_id 
FROM users 
WHERE users.id != 1 AND (NOT EXISTS (SELECT friendships.id FROM friendships
                  WHERE users.id = friendships.user_id OR users.id = friendships.friend_id)
                  OR
                  EXISTS(SELECT friendships.id FROM friendships
                         WHERE (users.id = friendships.user_id OR users.id = friendships.friend_id) AND (friendships.status != 'blocked' OR friendships.blocker = 1)));

JOIN friendships ON users.id = friendships.user_id OR users.id = friendships.friend_id
                  
=end