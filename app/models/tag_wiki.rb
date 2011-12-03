class TagWiki < ActiveRecord::Base
  belongs_to :tag
  belongs_to :language
  has_paper_trail
  
  def can_edit?(user)
    user && user.created_at > 3.months.ago
  end
  
  def language_name
    (language && language.name) || "English"
  end
end