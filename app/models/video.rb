class Video < ApplicationRecord
  include Chaptery
  include VideoUploader::Attachment.new(:video)

  ### ASSOCIATIONS

  ### VALIDATIONS

  ### CALLBACKS

  ### CLASS METHODS

  ## INSTANCE METHODS
end
