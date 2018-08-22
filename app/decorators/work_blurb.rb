class WorkBlurb < SimpleDelegator
  delegate :url_helpers, to: 'Rails.application.routes'
  
  attr_writer :tags, :pseuds, :stats, :series, :collection_count

  def tags
    @tags ||= super
  end

  def pseuds
    @pseuds ||= super
  end

  def stats
    @stats ||= stat_counter
  end

  def series
    @series ||= super
  end

  def collection_count
    @collection_count || approved_collections.count
  end

  # TODO: ANON and external authors
  def creator_links
    pseuds.map{ |p| creator_link(p) }
  end

  def creator_link(pseud)
    login = pseud.u_name
    url = url_helpers.user_pseud_works_url(
      user_id: login,
      pseud_id: pseud.name,
      host: ArchiveConfig.APP_HOST
    )
    { name: pseud.byline, url: url }
  end

  def series_links
    series.map{ |s| series_link(s) }
  end

  def series_link(ser)
    {
      position: ser.position,
      title: ser.title,
      url: url_helpers.series_url(id: ser.id, host: ArchiveConfig.APP_HOST)
    }
  end

  def tag_groups
    tags.group_by(&:type)
  end

  # A hash of tag links keyed by type
  def tag_data
    return {} unless tags.present?
    tags.inject({}) do |data, tag|
      data[tag.type] ||= []
      data[tag.type] << tag_link(tag)
      data
    end
  end

  def tag_links
    types = Tag::TAGGABLE_TYPES - ['Fandom']
    types.map { |type| tag_data[type] }.flatten.compact
  end

  def tag_link(tag)
    url = url_helpers.tag_works_url(
      tag_id: tag.to_param,
      host: ArchiveConfig.APP_HOST
    )
    { name: tag.name, url: url }
  end

  def fandom_links
    tag_data['Fandom'] || []
  end

  def recipients
  end

  def comments_count
    stats.comments_count
  end

  def kudos_count
    stats.kudos_count
  end

  def bookmarks_count
    stats.bookmarks_count
  end

  def show_hit_count?
    true
  end

  def hits
    stats.hit_count
  end

  def language_name
    "English"
  end
end
