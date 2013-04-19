module Redmine
  module WikiFormatting
    module Textile
      module Helper
        def heads_for_wiki_formatter
          [
            stylesheet_link_tag('jstoolbar'),
            stylesheet_link_tag('css-tooltips', :plugin => 'redmine_amanzi'),
            stylesheet_link_tag('inline', :plugin => 'redmine_amanzi'),
            javascript_include_tag('raphael', :plugin => 'redmine_amanzi')
            #javascript_include_tag('jquery-1.8.2.min.js', :plugin => 'redmine_amanzi')
          ].join("\n")
        end
      end
    end
  end
end
