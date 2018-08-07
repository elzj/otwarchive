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
    Tags::Document.new(object).as_json
  end

end
