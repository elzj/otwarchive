module Tags
  class Document < SimpleDelegator
    WHITELISTED_FIELDS = %i(id name sortable_name merger_id canonical created_at)

    def as_json(options = nil)
      super(
        root:     false,
        only:     WHITELISTED_FIELDS
      ).merge(
        tag_type: type,
        uses:     taggings_count_cache,
        suggest:  suggester
      ).merge(parent_data)
    end

    # You can't combine contexts, so if we want to be able to filter
    # by canonical whatevers, we need to smush that data together
    def suggester
      {
        input:    suggester_tokens,
        weight:   suggester_weight,
        contexts: {
          typeContext: [
            type,
            canonical? ? "Canonical#{type}" : nil
          ].compact
        }
      }
    end
  
    # Index parent data for tag wrangling searches
    def parent_data
      %w(Media Fandom Character).each_with_object({}) do |parent_type, data|
        if parent_types.include?(parent_type)
          new_data = parent_data_for(parent_type)
          data[:parent_ids] ||= []
          data[:parent_ids] += new_data["parent_ids"]
          data.merge!(new_data)
        end
      end
    end

    # Returns a hash of parent tag data
    # Returns parent_ids as a string array so we can use them
    # as a suggester context (which doesn't work with integers)
    # Adds a dummy value for unwrangled tags since you can't
    # search for an empty array
    # Don't bother trying to look up suggested tags for media
    # since media tags aren't used on works
    def parent_data_for(parent_type)
      key       = "#{parent_type.downcase}_ids"
      ids       = parents.by_type(parent_type).pluck(:id)
      data      = { "parent_ids" => ids.map(&:to_s) }
      data[key] = ids.empty? ? [0] : ids
      unless parent_type == "Media"
        data["pre_#{key}"] = suggested_parent_ids(parent_type)
      end
      data
    end
  end
end
