class FandomTag < ActiveRecord::Base
  validates_presence_of :name
  validates_uniqueness_of :name

  validates_presence_of :slug
  validates_uniqueness_of :slug
  
  has_many :fandom_taggings, :as => :fandom_tagger
  has_many :fandoms, :through => :fandom_taggings
  
  belongs_to :parent, :class_name => 'FandomTag'
  has_many :children, :foreign_key => :parent_id, :class_name => 'FandomTag'
  
  VALID_TYPES = %w(FandomCountry FandomGenre FandomMedium)
  
  def to_param
    slug
  end
  
  before_validation :set_slug
  
  def set_slug
    self.slug = self.name.parameterize
  end
end
