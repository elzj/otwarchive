class FilterManager
  
  def process!
    # do all the things
  end
  
  # Format: [tag_id, filter_id]
  def add_filter_to_tag
    @addition_list ||= []
  end
  
  # Format: [tag_id, filter_id]
  def remove_filter_from_tag
    @removal_list ||= []
  end
  
  # Format: [tag_id, old_filter_id, new_filter_id]
  def move_filters
    @move_filters ||= []
  end
  
  def no_longer_canonical
    @no_longer_canonical ||= []
  end
  
  def newly_canonical
    @newly_canonical ||= []
  end
  
  # Remove common tagging association between two tags
  def remove_associations
    @remove_association_list ||= []
  end
  
end