class WorkTypeTagging < ActiveRecord::Base
  belongs_to :work
  belongs_to :work_type

  validates :work
  validates :work_type
end
