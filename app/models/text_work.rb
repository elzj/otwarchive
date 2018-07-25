class TextWork < Work
  def self.model_name
    Work.model_name
  end

  validates_associated :chapters
  before_save :set_word_count

  # Set the value of word_count to reflect the length of the chapter content
  # Called before_save
  def set_word_count
    if self.new_record?
      self.word_count = 0
      chapters.each do |chapter|
        self.word_count += chapter.set_word_count
      end
    else
      self.word_count = Chapter.select("SUM(word_count) AS work_word_count").where(work_id: self.id, posted: true).first.work_word_count
    end
  end
end
