module FilterManagement
  class MetaTagCleanup
    attr_reader :target, :meta_tag

    def initialize(target, meta_tag)
      @target = target
      @meta_tag = meta_tag
    end

    # Break the connection between this tag's subtags and works
    # and the metatag in question and all of its ancestors
    def perform!
      remove_from_sub_tags
      remove_inherited_meta_tags
      update_works
    end

    private

    # Remove the metatag from this tag's subtags
    def remove_from_sub_tags
      target.sub_tags.each do |sub|
        delete_meta_tag(sub, meta_tag)
      end
    end

    # Remove all the meta taggings from higher up the tree from
    # all the sub tags lower down the tree
    def remove_inherited_meta_tags
      meta_grandparents.each do |grandparent|
        tag_and_subs.each do |tag|
          delete_meta_tag(tag, grandparent)
        end
      end
    end

    # Remove the inherited metatags from this tag's works
    def update_works
      to_remove = [meta_tag] + meta_grandparents
      target.filtered_works.find_each do |work|
        to_remove.each do |tag|
          if should_untag_work?(work, tag)
            work.filter_taggings.where(filter_id: tag.id).destroy_all
            RedisSearchIndexQueue.reindex(work, priority: :low)
          end
        end
      end
      meta_tag.update_works_index_timestamp!
    end

    def delete_meta_tag(tag, meta)
      if tag.meta_tags.include?(meta)
        tag.meta_tags.delete(meta)
      end
    end

    # The metatags of my metatag are my metatags
    # at least until they aren't anymore
    def meta_grandparents
      @meta_grandparents ||= meta_tag.meta_tags
    end

    def tag_and_subs
      @tag_and_subs ||= [target] + target.sub_tags
    end

    # Other subtags of this metatag that are not part of
    # this tag's inheritence branch
    def other_sub_tags
      @other_sub_tags ||= meta_tag.sub_tags - tag_and_subs
    end

    # Ditch this tag if the work is tagged with it
    # and the work isn't getting the filter from a different subtag
    # and the work isn't tagged with it directly
    # or with any of its synonyms
    def should_untag_work?(work, tag)
      work.filters.include?(tag) &&
        (work.filters & other_sub_tags).empty? &&
        !work.tags.include?(tag) &&
        (work.tags & tag.mergers).empty?
    end
  end
end