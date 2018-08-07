module StringTokenizer
  extend self

  # Takes a multi-word string and turns it into an array of tokens
  # suitable for use in an autocomplete feature
  def tokenize(str)
    return [] if str.nil?
    tokens = [str]
    words = str.split(/[\s\/\&]+/)
    while words.length > 0
      words.shift
      next if words.first.nil?
      tokens << words.join(" ")
    end
    tokens.uniq.take(20)
  end
end