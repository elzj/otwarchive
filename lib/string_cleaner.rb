module StringCleaner

  STOP_WORDS = %w(a an and are as at be but by for if in into
    is it no not of on or such that the their then there these
    they this to was with).freeze

  def remove_articles_from_string(str)
    str.gsub(article_removing_regex, '')
  end

  def article_removing_regex
    Regexp.new(/^(a|an|the|la|le|les|l'|un|une|des|die|das|il|el|las|los|der|den)\s/i)
  end

  def stop_word?(word)
    STOP_WORDS.include?(word.downcase) || article_removing_regex =~ "#{word} "
  end

end
  
