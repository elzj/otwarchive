class FandomTagging < ActiveRecord::Base
  belongs_to :fandom
  belongs_to :fandom_tagger, :polymorphic => true
end
