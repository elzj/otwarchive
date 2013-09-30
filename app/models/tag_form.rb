class TagForm
  
  extend ActiveModel::Naming
  extend ActiveModel::Callbacks
  include ActiveModel::Conversion
  include ActiveModel::Validations
  
  def persisted?
    false
  end

  def self.model_name
    ActiveModel::Name.new(self, nil, "Tag")
  end
  
  define_model_callbacks :save
  
  ###############
  # VALIDATIONS #
  ###############
  
  validate :unwrangleable_status
  validate :allowed_to_change_name
  validate :allowed_to_change_type
  validate :canonical_synonym
  validate :no_canonical_synonyms
  validate :no_self_synonyms
  validate :no_cross_type_synonyms
  
  def unwrangleable_status
    if unwrangleable && (canonical || merger_id.present?)
      self.errors.add(:unwrangleable, "can't be set on a canonical or synonymized tag.")
    end
  end

  # ordinary wranglers can change case and accents but not punctuation or the actual letters in the name
  # admins can change tags with no restriction
  def allowed_to_change_name
    if !tag.new_record? && tag.name_changed?
      unless User.current_user.is_a?(Admin) || name_case_change? || name_accent_change?
        self.errors.add(:name, "can only be changed by an admin.")
      end
    end
  end
  
  def allowed_to_change_type
    if type_changed? && !tag.can_change_type?
      self.errors.add(:type, "cannot be changed for this tag.")
    end
  end
  
  def canonical_synonym
    if tag.merger && !tag.merger.canonical?
      self.errors.add(:base, '<a href="/tags/' + tag.merger.to_param + '/edit">' + tag.merger.name + '</a> is not a canonical tag. Please make it canonical before adding synonyms to it.')
    end
  end
    
  def no_canonical_synonyms
    if merger_id && canonical
      self.errors.add(:base, "A canonical can't be a synonym of another tag.")
    end
  end
  
  def no_self_synonyms
    if merger_id == tag.id
      self.errors.add(:base, "A tag can't be a synonym of itself.")
    end
  end
  
  def no_cross_type_synonyms
    unless tag.merger.class == tag.class
      self.errors.add(:base, "A tag can only be a synonym of a tag in the same category as itself.")
    end
  end
  
  ########################
  # ATTRS AND DELEGATION #
  ########################
  
  attr_reader :tag

  delegate :name, :sortable_name, :type, :canonical, :unwrangleable, :merger_id, 
    :name_was, :type_changed?, :type_was, to: :tag
  
  ##################
  # PUBLIC METHODS #
  ##################
  
  def initialize(tag)
    @tag = tag
    @filter_manager = FilterManager.new
  end
  
  def update(params)
    tag.attributes = params.slice(:name, :sortable_name, :type, :canonical, :unwrangleable, :merger_id)
    association_fields = %w(syn merger media fandom character relationship freeform meta_tag sub_tag)
    association_fields.each do |assoc|
      if params["#{assoc}_string"].present?
        self.send("#{assoc}_string=", params["#{assoc}_string"])
      end
    end
    if params[:associations_to_remove].present?
      self.associations_to_remove = params[:associations_to_remove]
    end
    valid? ? save : false
  end
  
  def save
    tag.save!
    @filter_manager.process!
    true
  end
  
  # Overriding to include tag model validations
  def valid?
    super
    unless tag.valid?
      tag.errors.keys.each do |key|
        self.errors.add(key, tag.errors[key])
      end
    end
    self.errors.empty?
  end
  
  ###############
  # FORM FIELDS #
  ###############
  
  attr_reader :media_string, 
              :fandom_string, 
              :character_string, 
              :relationship_string, 
              :freeform_string, 
              :meta_tag_string, 
              :sub_tag_string, 
              :merger_string

  # We're using syn_string here to refer to the (parent) merger of this tag
  # And merger_string to refer to this tag's (child) mergers
  def syn_string
    tag.merger.name if tag.merger
  end
  
  # Make this tag a synonym of another tag -- merger_name is the name of the other tag (which should be canonical)
  # NOTE for potential confusion
  # "merger" is the canonical tag of which this one will be a synonym
  # "mergers" are the tags which are (currently) synonyms of THIS one
  # Bounce out right away if there's no change
  def syn_string=(merger_name)
    return if merger_name.blank? && tag.merger_id.blank?
    return if tag.merger.present? && merger_name == tag.merger.name
    if merger_name.blank?
      remove_filters_for(tag.id, tag.merger_id)
      tag.merger_id = nil
    else
      new_merger = Tag.find_by_name(merger_name)
      if new_merger.nil?
        new_merger = create_new_merger(tag.class, merger_name)
      end
      if new_merger.present?
        tag.canonical = false
        tag.merger_id = new_merger.id
        add_filters_for(tag.id, new_merger.id)
      end
    end
  end
  
  # Add one or more existing non-canonical tags as synonyms
  # of this tag
  def merger_string=(tag_string)
    names = tag_string.split(',').map(&:squish)
    names.each do |name|
      syn = Tag.find_by_name(name)
      if syn && !syn.canonical?
        if syn.merger_id.present?
          remove_filters_for(syn.id, syn.merger_id)
        end
        syn.update_attributes(:merger_id => self.id)
        add_filters_for(syn.id, tag.id)
      end
    end
  end
  
  # Funnel all the cross-class associations to a central method
  %w(fandom media character relationship freeform).each do |tag_type|
    define_method("#{tag_type}_string=") do |tag_string|
      add_parent_string(tag_string)
    end
  end

  # A list of meta tags to connect to this tag
  def meta_tag_string=(tag_string)
    names = tag_string.split(',').map(&:squish)
    names.each do |name|
      if parent = tag.class.find_by_name(name)
        create_meta_tagging(parent, tag)
      end
    end
  end
  
  # A list of sub tags to connect to this tag
  def sub_tag_string=(tag_string)
    names = tag_string.split(',').map(&:squish)
    names.each do |name|
      if sub = self.class.find_by_name(name)
        create_meta_tagging(tag, sub)
      end
    end
  end

  def associations_to_remove
    @associations_to_remove ||= []
  end
  
  def associations_to_remove=(taglist)
    taglist.reject {|tid| tid.blank?}.each do |tag_id|
      remove_association(tag.id, tag_id)
    end
  end
 
  ###################
  # CALLBACKS #######
  ###################
  
  before_save :check_type_changes, :if => :type_changed?
  before_save :check_for_canonical_change
  before_save :check_for_merger_change

  # if the tag used to be a Fandom and is now something else, no parent type will fit, remove all parents
  # if the tag had a type and is now an UnsortedTag, it can't be put into fandoms, so remove all parents
  # if the tag has just become a Fandom, it needs the Uncategorized media added to it manually, 
  # and no other parents (the after_save hook on Fandom won't take effect, since it's not a Fandom yet)
  def check_type_changes
    return if type_was.nil?
    if type_was == "Fandom" || type == "UnsortedTag"
      tag.parents = []
    elsif type == "Fandom"
      tag.parents = [Media.uncategorized]
    end
  end
  
  def check_for_canonical_change
    if tag.canonical_changed?
      if tag.canonical?
        @filter_manager.newly_canonical << tag.id
      else
        @filter_manager.no_longer_canonical << tag.id
      end
    end
  end
  
  def check_for_merger_change
    if tag.merger_id_changed?
      if tag.merger_id_was.present?
        if tag.merger_id.present?
          move_filters_to_new_merger(tag.id, tag.merger_id_was, tag.merger_id)
        else
          remove_filters_for(tag.id, tag.merger_id_was)
        end
      elsif tag.merger_id.present?
        add_filters_for(tag.id, tag.merger_id)
      end
    end
  end
  
  ###################
  # PRIVATE METHODS #
  ###################
  
  # Helper methods
  
  def name_case_change?
    name.downcase == name_was.downcase
  end
  
  def name_accent_change?
    asciid(name) == asciid(name_was)
  end
  
  def asciid(str)
    str.mb_chars.normalize(:kd).gsub(/[^\x00-\x7F]/u,'').downcase.to_s
  end
  
  # Feed changes to the filter manager to be executed later
  
  def add_filters_for(tag_id, filter_id)
    @filter_manager.add_filter_to_tag << [tag_id, filter_id]
  end
  
  def remove_filters_for(tag_id, filter_id)
    @filter_manager.remove_filter_from_tag << [tag_id, filter_id]
  end
  
  def move_filters_to_new_merger(tag_id, old_filter_id, new_filter_id)
    @filter_manager.move_filters << [tag_id, old_filter_id, new_filter_id]
  end
  
  def remove_association_for(tag_id, associate_id)
    @filter_manager.remove_associations << [tag_id, associate_id]
  end
  
  # Add a common tagging association
  # ie. add a character to a fandom, add a fandom to a media
  def add_parent_string(tag_string)
    names = tag_string.split(',').map(&:squish)
    names.each do |name|
      parent = Tag.find_by_name(name)
      tag.add_association(parent) if parent && parent.canonical?
    end
  end
  
  # Create a new canonical tag to become this tag's merger
  def create_new_merger(klass, merger_name)
    new_merger = klass.new(name: merger_name, canonical: true)
    if new_merger.save
      new_merger
    else
      self.errors.add(:base, merger_name + " could not be saved. Please make sure that it's a valid tag name.")
      nil
    end
  end
  
  # Create a meta tagging relationship between two tags
  def create_meta_tagging(meta, sub)
    meta_tagging = sub.meta_taggings.build(:meta_tag => meta, :direct => true)
    unless meta_tagging.valid? && meta_tagging.save
      self.errors.add(:base, "You attempted to create an invalid meta tagging. :(")
    end
  end
  
end