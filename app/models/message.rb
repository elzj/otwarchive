class Message < ActiveRecord::Base
  attr_accessible :body, :read, :recipient_id, :replied_to, :sender_id, :thread_id, :title, :type

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

end
