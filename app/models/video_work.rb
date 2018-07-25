class VideoWork < Work
  def self.model_name
    Work.model_name
  end

  has_many :videos, foreign_key: 'work_id'
  has_many :chapters, class_name: 'Video', foreign_key: 'work_id'

  def thumbnail
    chapters.first&.video_file(:thumb)
  end

  def length
    chapters.first&.vid_length
  end

  def length_label
    "Duration"
  end

  def work_types
    ["Video"]
  end
end
