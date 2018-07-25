class TagIndexer < Indexer

  def self.klass
    "Tag"
  end

  def self.mapping
    {
      tag: {
        properties: {
          name: {
            type: "text",
            analyzer: "tag_name_analyzer",
            fields: {
              exact: {
                type:     "text",
                analyzer: "exact_tag_analyzer"
              }
            }
          },
          tag_type: { type: "keyword" },
          sortable_name: { type: "keyword" },
          uses: { type: "integer" },
          parent_ids: { type: "keyword" },
          suggest: {
            type: "completion",
            contexts: [
              { 
                name: "typeContext",
                type: "category"
              },              
              { 
                name: "parentContext",
                type: "category",
                path: "parent_ids"
              }
            ]
          }
        }
      }
    }
  end

  def self.settings
    {
      analysis: {
        analyzer: {
          tag_name_analyzer: {
            type: "custom",
            tokenizer: "standard",
            filter: [
              "lowercase"
            ]
          },
          exact_tag_analyzer: {
            type: "custom",
            tokenizer: "keyword",
            filter: [
              "lowercase"
            ]
          }
        }
      }
    }
  end

  def document(object)
    object.as_json(
      root: false,
      only: [:id, :name, :merger_id, :canonical, :created_at, :sortable_name]
    ).merge(
      tag_type: object.type,
      uses: object.taggings_count_cache,
      suggest: {
        input: object.suggester_tokens,
        weight: object.suggester_weight,
        contexts: {
          typeContext: [
            object.type,
            object.canonical? ? "Canonical#{object.type}" : nil
          ].compact
        }
      }
    ).merge(parent_data(object))
  end

  # Index parent data for tag wrangling searches
  def parent_data(tag)
    data = {}
    parents = tag.parents.select(:id, :type).group_by(&:type)
    data[:parent_ids] = parents.values.flatten.map{ |t| t.id.to_s }
    %w(Media Fandom Character).each do |parent_type|
      next unless tag.parent_types.include?(parent_type)
      key = "#{parent_type.downcase}_ids"
      ids = parents[parent_type] ? parents[parent_type].map(&:id) : [0]
      data[key] = ids
      next if parent_type == "Media"
      data["pre_#{key}"] = tag.suggested_parent_ids(parent_type)
    end
    data
  end
end
