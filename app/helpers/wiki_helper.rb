module Redmine
  module WikiFormatting
    module Textile
      module Helper
        def heads_for_wiki_formatter
          stylesheet_link_tag 'jstoolbar'
          javascript_include_tag 'raphael', :plugin => 'redmine_amanzi'
        end
      end
    end
  end
end
