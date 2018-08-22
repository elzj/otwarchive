class WorkList
  attr_reader :search_results

  def initialize(search_results)
    @search_results = search_results
  end

  def work_ids
    @work_ids ||= search_results.map{ |hit| hit['_id'].to_i }
  end

  def works
    return @works if @works
    works = Work.where(id: work_ids).group_by(&:id)
    @works = work_ids.map{ |id| works[id]&.first }.compact
  end

  def blurbs
    works.map do |work|
      WorkBlurb.new(work).tap do |blurb|
        blurb.tags    = tags[work.id]
        blurb.pseuds  = pseuds[work.id]
        blurb.stats   = stats[work.id]&.first
        blurb.series  = series[work.id] || []
        blurb.collection_count = collections[work.id].length
      end
    end
  end

  def tags
    @tags ||= Tag.all_for_works(work_ids)
  end

  def pseuds
    @pseuds ||= Pseud.all_for_works(work_ids)
  end

  def series
    @series ||= Series.all_for_works(work_ids)
  end

  # We don't actually need the collections for blurbs,
  # just the number of collections, so we can use the search data
  def collections
    @collections ||= search_results.inject({}) do |data, hit|
      work_id = hit['_id'].to_i
      collection_ids = hit.dig('_source', 'collection_ids') || []
      data.merge(work_id => collection_ids)
    end
  end

  def stats
    @stats ||= StatCounter.where(work_id: work_ids).group_by(&:work_id)
  end
end
