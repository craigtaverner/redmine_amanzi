module ApplicationHelper

  def render_page_list(pages, node=nil, options = {:sort => true})
    content = ''
    if pages[node]
      content << "<ul class=\"pages-list\">\n"
      if options[:sort]
        pages[node] = pages[node].sort{|x,y| fudge_version_order(x.title) <=> fudge_version_order(y.title)}
      end
      pages[node].each do |page|
        content << "<li>"
        content << link_to(h(page.pretty_title), {:controller => 'wiki', :action => 'index', :id => page.project, :page => page.title},
                           :title => (page.respond_to?(:updated_on) ? l(:label_updated_time, distance_of_time_in_words(Time.now, page.updated_on)) : nil))
        content << "\n" + render_page_hierarchy(pages, page.id) if pages[page.id]
        content << "</li>\n"
      end
      content << "</ul>\n"
    end
    content
  end

  def fudge_version_order(text)
    text.gsub(/(Mile|Proto|M\d)/i,'0\1').gsub(/(Future)/i,'zzz\1')
  end

end
