module FilterManagement
  class FilterRemover
    attr_reader :target, :old_syn

    def initialize(target, old_synonym_id)
      @target = target
      @old_syn = Tag.find(old_synonym_id)
    end

    # We're removing a tag from its old filter/synonym
    # so we want to go through the works and remove the filter from them
    # and the filter's metatags, unless they should be there for another reason
    def perform!
      target.works.find_each do |work|
        filters_to_remove.each do |filter_to_remove|
          next unless work.filters.include?(filter_to_remove)
          remove_filter_from_work(work, filter_to_remove)
        end
      end
    end

    private

    def remove_filter_from_work(work, filter)
      filter_tagging = work.filter_taggings.where(filter_id: filter.id).first
      if filter_tagging.should_exist?
        if filter_is_inherited?(work, filter)
          filter_tagging.update_attribute(:inherited, true)
        end
      else
        filter_tagging.destroy
      end
    end

    # The filter is inherited if there's no overlap between the work tags
    # and the filter itself or its direct synonyms/mergers
    def filter_is_inherited?(work, filter)
      (work.tags & ([filter] + filter.mergers - [target])).empty?
    end

    def filters_to_remove
      @filters_to_remove ||= [old_syn] + old_syn.meta_tags
    end
  end
end