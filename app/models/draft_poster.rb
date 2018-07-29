class DraftPoster
  REQUIRED_FIELDS = %i(title fandoms ratings warnings creators)
  attr_reader :draft, :errors
  
  def initialize(draft)
    @draft = draft
    @errors = []
  end

  def post!
    begin
      valid? && Draft.transaction {
        work = save_work
        save_tags(work)
        draft.destroy
        work
      }
    rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotSaved => e
      @errors << e.message
      false
    end
  end

  def valid?
    REQUIRED_FIELDS.each do |field|
      if draft.send(field).blank?
        errors << "#{field.to_s.classify} is missing"
      end
    end
    errors.empty?
  end

  def save_work
    Work.new(draft.work_data.merge(posted: true)).tap do |work|
      work.authors = Pseud.find(draft.creators)
      work.chapters.build(draft.chapter_data.merge(posted: true))
      work.save!
    end
  end


  def save_tags(work)
    draft.tag_data.each_pair do |tag_type, tag_string|
      next if tag_string.blank?
      if tag_string.is_a?(Array)
        tag_string = tag_string.reject(&:empty?).join(',')
      end
      tags = Tag.process_list(tag_type, tag_string)
      tags.each do |tag|
        work.taggings.create!(tagger_id: tag.id, tagger_type: 'Tag')
      end
    end
  end
end