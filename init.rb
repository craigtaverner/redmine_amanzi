require 'redmine'

require_dependency 'amanzi_macros'

Redmine::Plugin.register :redmine_amanzi do
  name 'Amanzi Extensions'
  author 'Craig Taverner'
  description 'This is a testbed for redmine extensions of interest to Amanzi. The first piece is a template macro for the wiki pages.'
  version '0.0.1'

  url 'http://redmine.amanzi.org/projects/show/redmine-amanzi'
  author_url 'http://www.amanzi.org/craig'

  requires_redmine :version_or_higher => '0.8.0'
end
