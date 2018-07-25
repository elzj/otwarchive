module Chaptery
  def self.included(chapter)
    chapter.class_eval do
      has_many :creatorships, as: :creation
      has_many :pseuds, through: :creatorships
      belongs_to :work
      acts_as_commentable
      has_many :kudos, as: :commentable

      scope :in_order, -> { order(:position) }
      scope :posted, -> { where(posted: true) }
    end
    chapter.extend(ClassMethods)
  end

  module ClassMethods
  end

end
