class BookmarkIndexer

  CLIENT = Elasticsearch::Model.client

  attr_reader :bookmark

  def initialize(bookmark)
    @bookmark = bookmark
  end

  ####### CLASS METHODS

  def self.create_mapping
    CLIENT.indices.put_mapping(
      index: index_name,
      type: "bookmark",
      body: mapping
    )
  end

  def self.mapping
    {
      "bookmark" => {
        "_parent" => {
          type: 'bookmarkable'
        },
        properties: {
          notes: {
            type: 'string',
            analyzer: 'snowball'
          }
        }
      }
    }
  end

  def self.index_name(type=nil)
    "ao3_#{Rails.env}_bookmarks"
  end

  ####### INSTANCE METHODS

  def index_name
    self.class.index_name
  end

  def document_type
    'bookmark'
  end

  def index_document
    CLIENT.index(
      { index: index_name,
        type: document_type,
        id: bookmark.id,
        parent: bookmark.bookmarkable_id,
        body: as_indexed_json
      }
    )
  end

  def update_document
    CLIENT.update(
      { index: index_name,
        type: document_type,
        id: bookmark.id,
        parent: bookmark.bookmarkable_id,
        body:  { doc: changed_attributes }
      }
    )
  end

  def delete_document
    CLIENT.delete(
      { index: index_name,
        type: document_type,
        id: bookmark.id,
        parent: bookmark.bookmarkable_id
      }
    )
  end

  def as_indexed_json
    bookmark.as_json(
      root: false,
      except: [:notes_sanitizer_version, :delta],
      methods: [:bookmarker, :collection_ids, :with_notes, :tag, :tag_ids, :filter_ids]
    )
  end

  def changed_atributes
    changed_keys = bookmark.changed_attributes.map
    bookmark.changed_attributes.select { |k,v| as_indexed_json.keys.include? k }
  end

end
