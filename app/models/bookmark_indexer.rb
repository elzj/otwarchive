class BookmarkIndexer

  CLIENT = Elasticsearch::Model.client

  def initialize(bookmark)
    @bookmark = bookmark
  end

  ####### CLASS METHODS

  def self.create_mappings
    %w(work series external_work).each do |type|
      CLIENT.indices.put_mapping(
        { index: index_name(type),
          type: "#{type}_bookmark",
          body: mapping(type)
        }
      )
    end
  end

  def self.mapping(type)
    {
      "#{type}_bookmark" => {
        "_parent" => type.underscore,
        properties: {

        }
      }
    }
  end

  def self.index_name(type)
    "ao3_#{Rails.env}_#{type.pluralize}"
  end

  ####### INSTANCE METHODS

  def index_name
    self.class.index_name(parent_type)
  end

  def parent_type
    bookmark.bookmarkable_type.underscore
  end

  def document_type
    "#{parent_type}_bookmark"
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
