class Download
  # Given a work and a format or mime type, generate a download file
  def self.generate(work, options = {})
    new(work, options).generate
  end

  # Remove all downloads for this work
  def self.remove(work)
    new(work).remove
  end

  attr_reader :work, :file_type, :mime_type

  def initialize(work, options = {})
    @work = work
    @file_type = set_file_type(options.slice(:mime_type, :format))
    @mime_type = MIME::Types.type_for(@file_type).first
  end

  def generate
    DownloadWriter.new(self).write
    self
  end

  def exists?
    File.exist?(file_path)
  end

  # Removes not just the file but the whole directory
  # Should change if our approach to downloads ever changes
  def remove
    FileUtils.rm_rf(dir)
  end

  # Given either a file extension or a mime type, figure out
  # what format we're generating
  # Defaults to html
  def set_file_type(options)
    if options[:mime_type]
      file_type_from_mime(options[:mime_type])
    elsif ArchiveConfig.DOWNLOAD_FORMATS.include?(options[:format].to_s)
      options[:format].to_s
    else
      "html"
    end
  end

  # Given a mime type, return a file extension
  def file_type_from_mime(mime)
    ext = MimeMagic.new(mime.to_s).subtype
    ext == "x-mobipocket-ebook" ? "mobi" : ext
  end

  # The base name of the file (eg, "War and Peace")
  def file_name
    name = clean(work.title)
    name += " Work #{work.id}" if name.length < 3
    name
  end

  # The public route to this download
  def public_path
    "/downloads/#{work.id}/#{file_name}.#{file_type}"
  end

  # The full path to the file (eg, "/tmp/42/The Hobbit.epub")
  def file_path
    "#{dir}/#{file_name}.#{file_type}"
  end

  # Write to temp and then immediately clean it up
  def dir
    "/tmp/#{work.id}"
  end

  # Utility methods which clean up work data for use in downloads

  def fandoms
    string = work.fandoms.size > 3 ? "Multifandom" : work.fandoms.string
    clean(string)
  end

  def authors
    author_names.join(', ').to_ascii
  end

  def author_names
    work.anonymous? ? ["Anonymous"] : work.pseuds.sort.map(&:name)
  end

  # need the next two to be filesystem safe and not overly long
  def file_authors
    clean(author_names.join('-'))
  end

  def page_title
    [file_name, file_authors, fandoms].join(" - ")
  end
  
  def chapters
    work.chapters.order('position ASC').where(posted: true)
  end

  private

  # make filesystem-safe
  # ascii encoding
  # squash spaces
  # strip all alphanumeric
  # truncate to 24 chars at a word boundary
  def clean(string)
    # get rid of any HTML entities to avoid things like "amp" showing up in titles
    string = string.gsub(/\&(\w+)\;/, '')
    string = ActiveSupport::Inflector.transliterate(string)
    string = string.encode("us-ascii", "utf-8")
    string = string.gsub(/[^[\w _-]]+/, '')
    string = string.gsub(/ +/, " ")
    string = string.strip
    string = string.truncate(24, separator: ' ', omission: '')
    string
  end
end
