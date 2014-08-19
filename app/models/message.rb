class Message < ActiveRecord::Base
  attr_accessible :body, :read, :recipient_id, :replied_to, :sender_id, :thread_id, :title, :type

  validates :sender_id, presence: true
  validates :recipient_id, presence: true
  validates :body, presence: true

  after_create :notify_recipient

  ################################
  # CLASS METHODS
  ################################

  def self.for_user(user)
    where("recipient_id = ? OR sender_id = ?", user.id, user.id)
  end

  def self.for_sender(user)
    where(sender_id: user.id)
  end

  def self.for_recipient(user)
    where(recipient_id: user.id)
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

  def recipient
    User.where(id: recipient_id).first
  end

  def sender
    User.where(id: sender_id).first
  end

  def notify_recipient
    return if recipient.nil?
    WebsocketRails[recipient.channel_key].trigger 'new', self
  end

end
