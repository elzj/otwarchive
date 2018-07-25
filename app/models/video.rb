class Video < ApplicationRecord
  include Chaptery

    has_attached_file :video_file,
      path: ":attachment/:id/:style.:extension",
      storage: :s3,
      bucket: "vids",
      styles: {
        streaming: {
          format: 'mp4',
          # :geometry => "1200x675#",
          convert_options: {
            input: {},
            output: {
              vcodec: 'libx264',
              acodec: 'aac',
              movflags: '+faststart'
            }
          }
        },
        thumb: {
          format: 'jpg'  
        }
      },
      processors: [:transcoder]

  process_in_background :video_file
  validates_attachment_size :video_file, less_than: 1.gigabytes
  validates_attachment :video_file, content_type: { content_type: /\Avideo\/.*\Z/ }

  def vid_length
    video_file_meta.match(/\:length=>\"([\d\:]+)/) && $1
  end

  def content
    if video_file.present?
      f = video_file(:streaming)
      "<video src='#{f}' controls width='700' poster='#{video_file(:thumb)}'></video>"
    else
      read_attribute(:content)
    end
  end
end
