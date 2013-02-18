class ExternalWorkTypeTagging < ActiveRecord::Base
  belongs_to :external_work
  belongs_to :work_type

  validates :external_work
  validates :work_type
end
