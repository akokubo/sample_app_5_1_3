class Relationship < ApplicationRecord
  # Followerモデルは存在せず、実態はUser
  belongs_to :follower, class_name: "User"
  # Followedモデルは存在せず、実態はUser
  belongs_to :followed, class_name: "User"
  validates :follower_id, presence: true
  validates :followed_id, presence: true
end
