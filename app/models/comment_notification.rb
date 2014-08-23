class CommentNotification < Message
  validates :parent_id, presence: true
  validates :parent_type, presence: true

  before_validation :set_data_from_parent

  alias_method :comment, :parent

  ####################
  # CLASS METHODS
  ####################

  def self.create_from_comment(comment)
    comment.concerned_users.map do |user|
      create_for_user(user, comment)
    end
  end

  def self.create_for_user(user, comment)
    message = CommentNotification.new(user_id: user.id, parent: comment, created_at: comment.created_at)
    unless message.save
      # log this somewhere
    end
    message
  end

  ####################
  # INSTANCE METHODS
  ####################

  private

  def set_data_from_parent
    return false if parent.nil?
    set_sender
    set_recipient
    set_title
    set_body
    set_thread
  end

  def set_sender
    if comment.pseud.present?
      self.sender_id = comment.pseud.user_id
    end
    self.sender_name = comment.comment_owner_name
  end

  def set_recipient
    if !comment.reply_comment?
      users = comment.ultimate_parent.commentable_owners
      if users.length == 1
        self.recipient_id = users.first.id
      end
      self.recipient_name = users.map(&:login).to_sentence
    else
      parent_comment = comment.commentable
      self.recipient_id = parent_comment.pseud.try(:user_id)
      self.recipient_name = parent_comment.comment_owner_name
    end
  end

  def set_title
    self.title = "Comment on #{comment.commentable_name.truncate(100)}"
    if comment.reply_comment? #|| comment.edited?
      self.title = "Re: #{self.title}"
    end
  end

  def set_body
    self.body = comment.content
    if comment.edited?
      self.body << "<p>(edited on #{comment.edited_at})</p>"
    end
  end

  def set_thread
    self.thread_id = comment.thread
  end
end
