class Media < Tag
  include ActiveModel::ForbiddenAttributesProtection

  NAME = ArchiveConfig.MEDIA_CATEGORY_NAME
  DEFAULT_FANDOM_LISTING_SIZE = 5
  index_name Tag.index_name

  has_many :common_taggings, as: :filterable
  has_many :fandoms, -> { where(type: 'Fandom') }, through: :common_taggings, source: :common_tag

  def child_types
    ['Fandom']
  end

  # The media tag for unwrangled fandoms
  def self.uncategorized
    self.find_or_create_by_name(ArchiveConfig.MEDIA_UNCATEGORIZED_NAME)
  end

  def uncategorized?
    self.name == ArchiveConfig.MEDIA_UNCATEGORIZED_NAME
  end

  def add_association(tag)
    tag.parents << self unless tag.parents.include?(self)
  end

  def self.top_fandoms(options = {})
    self.all.inject({}) do |list, medium|
      list[medium] = medium.top_fandoms(options)
      list
    end
  end

  def top_fandoms(options = {})
    limit = options[:limit] || DEFAULT_FANDOM_LISTING_SIZE
    # Uncategorized fandoms aren't wrangled yet, so just show the latest
    if uncategorized?
      children.in_use.by_type('Fandom').order('created_at DESC').limit(limit)
    # For everything else, show the n most popular,
    # based on works visible to the current user
    else
      visible_scope = options[:logged_in] ? :unhidden_top : :public_top
      # was losing the select trying to do this through the parents association
      Fandom.send(visible_scope, limit).
             joins(:common_taggings).
             where(
              canonical: true,
              common_taggings: { filterable_id: id, filterable_type: 'Tag' }
             )
    end
  end
end
