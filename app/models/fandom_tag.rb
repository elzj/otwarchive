class FandomTag < ActiveRecord::Base
  validates_presence_of :name
  validates_uniqueness_of :name
  # disallowing url-unfriendly characters
  validates_format_of :name, :with => /\A[^,*<>^{}=`\\%\/\.\?#&]+\z/
  
  has_many :fandom_taggings, :as => :fandom_tagger
  has_many :fandoms, :through => :fandom_taggings
  
  VALID_TYPES = %w(FandomCountry FandomGenre FandomMedium)
  
  def to_param
    name
  end
end
