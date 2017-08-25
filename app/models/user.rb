class User < ApplicationRecord
  # データベースに存在しないremember_token属性を用意
  attr_accessor :remember_token
  before_save { self.email = email.downcase }
  validates :name, presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i 
  validates :email, presence: true, length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }
  has_secure_password
  validates :password, presence: true, length: { minimum: 6 }, allow_nil: true


  # Returns the hash digest of the given string.
  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  # Returns a random token.
  def User.new_token
    SecureRandom.urlsafe_base64
  end

  # Remembers a user in the database for use in persistent sessions.
  def remember
    # 新しくトークンを生成
    self.remember_token = User.new_token
    # ハッシュ化し、データベースにバリデーションをスルーして保存
    # バリデーションをスルーしないとパスワードが必要になる
    update_attribute(:remember_digest, User.digest(remember_token))
  end

  # Returns true if the given token matches the digest.
  def authenticated?(remember_token)
    # remember_digesetが空なら認証されていない
    # これは別のブラウザで同時にアクセスしていて、片方でログアウトした
    # ときの状況に対応している
    return false if remember_digest.nil?
    # remember_tokenをハッシュ化して、データベースに保存された
    # remember_digestと比較
    BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end

  # Forgets a user.
  def forget
    # バリデーションをスルーしてremember_digestを空にする
    # バリデーションをスルーしないとパスワードが必要になる
    update_attribute(:remember_digest, nil)
  end
end
