class Message < ActiveRecord::Base

  belongs_to :user
  belongs_to :parent, polymorphic: true
  belongs_to :sender, class_name: 'User'
  belongs_to :recipient, class_name: 'User'

  validates :user_id, presence: true
  validates :body, presence: true

  after_create :notify_recipient

  ################################
  # CLASS METHODS
  ################################

  def self.for_user(user)
    where(user_id: user.id)
  end

  def self.unread
    where(read: false)
  end

  def self.unreplied
    where(replied_to: false)
  end

  ################################
  # INSTANCE METHODS
  ################################

  def display_date
    if created_at > Time.now.beginning_of_day
      created_at.strftime("%l:%H %P")
    elsif created_at > Time.now.beginning_of_year
      created_at.strftime("%b %e")
    else
      created_at.strftime("%b %e, %Y")
    end
  end

  def notify_recipient
    return if recipient.nil?
    WebsocketRails[recipient.channel_key].trigger 'new', self
  end

end
