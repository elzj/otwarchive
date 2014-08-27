class BookmarkableIndexer

  CLIENT = Elasticsearch::Model.client

  attr_reader :bookmarkable

  def initialize(bookmarkable)
    @bookmarkable = bookmarkable
  end

  ####### CLASS METHODS

  def self.create_mapping
    CLIENT.indices.put_mapping(
      index: index_name,
      type: "bookmarkable",
      body: mapping
    )
  end

  def self.mapping
    {
      "bookmarkable" => {
        properties: {
        }
      }
    }
  end

  def self.index_name(type=nil)
    "ao3_#{Rails.env}_bookmarks"
  end

  ####### INSTANCE METHODS

  def id
    "#{bookmarkable.id}-#{bookmarkable.class.to_s.underscore}"
  end

  def index_name
    self.class.index_name
  end

  def index_document
    CLIENT.index(
      { index: index_name,
        type: 'bookmarkable',
        id: id,
        body: as_indexed_json
      }
    )
  end

  def update_document
    CLIENT.update(
      { index: index_name,
        type: 'bookmarkable',
        id: id,
        body:  { doc: changed_attributes }
      }
    )
  end

  def delete_document
    CLIENT.delete(
      { index: index_name,
        type: 'bookmarkable',
        id: id
      }
    )
  end

  def as_indexed_json
    bookmarkable.bookmarkable_json
  end

  def changed_atributes
    changed_keys = bookmarkable.changed_attributes.map
    bookmarkable.changed_attributes.select { |k,v| as_indexed_json.keys.include? k }
  end

end
