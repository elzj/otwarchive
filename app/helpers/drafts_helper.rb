module DraftsHelper
  def render_draft_form_part
    stages = %w(content tags series collections creators extras)
    if stages.include?(params[:stage]&.downcase)
      render "drafts/#{params[:stage]}_form"
    else
      render 'drafts/basics_form'
    end
  end

  def display_draft_media(draft)
    case draft.media.metadata['mime_type']
    when /image/
      image_tag draft.media_url
    when /audio/
      audio_tag draft.media_url, controls: true
    when /video\/[mp4|ogg|webm]/
      video_tag draft.media.url, controls: true
    else
      content_tag :p do
        link_to "Download", draft.media.url
      end
    end
  end
end