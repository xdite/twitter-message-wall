module TweetMessage
  module ViewHelpers
    
    def tag_options(options, escape = true)
      option_string = options.collect {|k,v| %{#{k}="#{v}"}}.join(' ')
      option_string = " " + option_string unless option_string.blank?
    end
 
    def content_tag(name, content, options, escape = true)
      tag_options = tag_options(options, escape) if options
      "<#{name}#{tag_options}>#{content}</#{name}>"
    end
 
    def link_to(text, link = nil, options = {})
      link ||= text
      link = url_for(link)
      "<a href=\"#{link}\">#{text}</a>"
    end

 
    def url_for(link_options)
      case link_options
      when Hash
        path = link_options.delete(:path) || request.path_info
        params.delete('captures')
        path + '?' + build_query(params.merge(link_options))
      else
        link_options
      end
    end
 
    def ts(time)
      time.strftime('%b %d, %Y') if time
    end

    
  end
end