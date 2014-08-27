module Bookmarkable

  def self.included(bookmarkable)
    bookmarkable.class_eval do
      has_many :bookmarks, :as => :bookmarkable
      has_many :user_tags, :through => :bookmarks, :source => :tags
      
      after_commit lambda { BookmarkableIndexer.new(self).index_document  },  on: :create
      after_commit lambda { BookmarkableIndexer.new(self).update_document },  on: :update
      after_commit lambda { BookmarkableIndexer.new(self).delete_document },  on: :destroy
    end
  end

  def public_bookmark_count
    Rails.cache.fetch("#{self.cache_key}/bookmark_count", :expires_in => 2.hours) do
      self.bookmarks.is_public.count
    end
  end

  # DEPRECATED
  def update_bookmarks_index
    RedisSearchIndexQueue.queue_bookmarks(self.bookmarks.value_of :id)
  end

  def bookmarkable_type
    self.class.to_s
  end

end
