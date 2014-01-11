require 'timeout'
require 'uri'

class UrlActiveValidator < ActiveModel::EachValidator
  include UrlHelpers

  # Checks the status of the webpage at the given url
  # To speed things up we ONLY request the head and not the entire page.
  # Bypass check for fanfiction.net because of ip block
  def validate_each(record,attribute,value)
    return true if value.match("fanfiction.net")
    inactive_url_msg = "could not be reached. If the URL is correct and the site is currently down, please try again later."
    record.errors[attribute] << (options[:message] || inactive_url_msg) unless url_active?(value)
  end
    
end
