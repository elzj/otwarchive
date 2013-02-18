class WorkType < ActiveRecord::Base
  validates :name, presence: true, uniqueness: true

  has_many :work_type_taggings
  has_many :works, through: :work_type_taggings

  has_many :external_work_type_taggings
  has_many :external_works, through: :external_work_type_taggings
end
