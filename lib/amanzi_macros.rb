# Dependency loading hell. http://www.ruby-forum.com/topic/166578#new
require 'dispatcher'
Dispatcher.to_prepare do
  Redmine::WikiFormatting::Macros.class_eval do

    # wiki template macro
    desc "Replace token inside a template. Example:\n\n !{{template(WikiTemplatePage,token=foo,token2=bar)}}."
    macro :template do |obj, args|
      page = Wiki.find_page(args.shift.to_s, :project => @project)
      raise 'Page not found' if page.nil? || !User.current.allowed_to?(:view_wiki_pages, page.wiki.project)

      @included_wiki_pages ||= []
      raise 'Circular inclusion detected' if @included_wiki_pages.include?(page.title)
      @included_wiki_pages << page.title
      out = textilizable(page.content, :text, :attachments => page.attachments)
      @included_wiki_pages.pop

      args.collect do |v|
        v[/(\w+)\W*\=\W*(.+)$/]
        key = $1
        value = $2.strip.gsub("<br />", "")
        out = out.gsub(key, value)
      end
      out
    end

    desc "Displays a toolbar of child pages. With no argument, it displays the child pages of the current wiki page. Examples:\n\n" +
           "  !{{child_page_list}} -- can be used from a wiki page only\n" +
           "  !{{child_page_list(Foo)}} -- lists all children of page Foo\n" +
           "  !{{child_page_list(Foo, parent=1)}} -- same as above with a link to page Foo"
    macro :child_page_list do |obj, args|
      args, options = extract_macro_options(args, :parent)
      page = nil
      if args.size > 0
        page = Wiki.find_page(args.first.to_s, :project => @project)
      elsif obj.is_a?(WikiContent)
        page = obj.page
      else
        raise 'With no argument, this macro can be called from wiki pages only.'
      end
      raise 'Page not found' if page.nil? || !User.current.allowed_to?(:view_wiki_pages, page.wiki.project)
      pages = ([page] + page.descendants).group_by(&:parent_id)
      render_page_list(pages, options[:parent] ? page.parent_id : page.id)
    end

    desc "Displays a list or toolbar of version wiki pages. Example:\n\n" +
           "  !{{version_pages}}\n\nor to display as a toolbar:\n\n" +
           "  !{{version_pages(toolbar=1)}}"
    macro :version_pages do |obj, args|
      args, options = extract_macro_options(args, :toolbar)
      pages = Version.find_all_by_project_id(@project.id).sort do |v1,v2|
        v1.effective_date <=> v2.effective_date
      end.map do |version|
        Wiki.find_page(version.wiki_page_title, :project => @project)
      end.compact.uniq
      options[:toolbar] ? render_page_list([pages],0,:sort=>false) : render_page_hierarchy([pages],0,:sort=>false)
    end

    desc "Embeds a YouTube video. Must pass the id of the video as an argument, for example:\n\n" +
         "  !{{youtube(nBMf1ulNM3s)}}\n" +
         "  !{{youtube(>nBMf1ulNM3s,use_hd)}} - right align and show in HD"
    macro :youtube do |obj, args|
      video_id = args.shift
      use_hd = false
      width = nil
      height = nil
      args.each do |arg|
        if arg=~/use_hd/
          use_hd=true
        elsif arg=~/width\s*\=\s*(\d+)/
          width=$1.to_i
        elsif arg=~/height\s*\=\s*(\d+)/
          height=$1.to_i
        end
      end
      if use_hd
        width = 695 if(width.nil?  || width.to_i  < 100)
        height =525 if(height.nil? || height.to_i < 100)
        video_html = '<object width="WIDTH" height="HEIGHT"><param name="movie" value="http://www.youtube.com/v/VIDEO_ID&hl=en_US&fs=1&hd=1&border=1"></param><param name="allowFullScreen" value="true"></param><param name="allowscriptaccess" value="always"></param><embed src="http://www.youtube.com/v/VIDEO_ID&hl=en_US&fs=1&hd=1" type="application/x-shockwave-flash" allowscriptaccess="always" allowfullscreen="true" width="WIDTH" height="HEIGHT"></embed></object>'
      else
        width = 435 if(width.nil?  || width.to_i  < 100)
        height =344 if(height.nil? || height.to_i < 100)
        video_html = '<object width="WIDTH" height="HEIGHT"><param name="movie" value="http://www.youtube.com/v/VIDEO_ID&hl=en_US&fs=1&"></param><param name="allowFullScreen" value="true"></param><param name="allowscriptaccess" value="always"></param><embed src="http://www.youtube.com/v/VIDEO_ID&hl=en_US&fs=1&" type="application/x-shockwave-flash" allowscriptaccess="always" allowfullscreen="true" width="WIDTH" height="HEIGHT"></embed></object>'
      end
      if video_id =~ /^[<>]/
        video_html="<div style=\"float: #{$1=='<' ? 'left' : 'right'}\">#{video_html}</div>"
        video_id=video_id[1..-1]
      end
      video_html.gsub(/VIDEO_ID/,video_id).gsub(/WIDTH/,width.to_s).gsub(/HEIGHT/,height.to_s)
    end

    desc "Embeds a Vimeo video. Must pass the id of the video as an argument, for example:\n\n" +
         "  !{{vimeo(nBMf1ulNM3s)}}\n" +
         "  !{{vimeo(>nBMf1ulNM3s,use_hd)}} - right align and show in HD"
    macro :vimeo do |obj, args|
      video_id = args.shift
      use_hd = false
      width = nil
      height = nil
      args.each do |arg|
        if arg=~/use_hd/
          use_hd = true
        elsif arg=~/width\s*\=\s*(\d+)/
          width = $1.to_i
        elsif arg=~/height\s*\=\s*(\d+)/
          height = $1.to_i
        end
      end
      if use_hd
        width = 715 if(width.nil?  || width.to_i  < 100)
        height =525 if(height.nil? || height.to_i < 100)
        video_html = '<iframe src="http://player.vimeo.com/video/VIDEO_ID" width="WIDTH" height="HEIGHT" frameborder="0"></iframe>'
      else
        width = 455 if(width.nil?  || width.to_i  < 100)
        height =344 if(height.nil? || height.to_i < 100)
        video_html = '<iframe src="http://player.vimeo.com/video/VIDEO_ID" width="WIDTH" height="HEIGHT" frameborder="0"></iframe>'
      end
      if video_id =~ /^[<>]/
        video_html="<div style=\"float: #{$1=='<' ? 'left' : 'right'}\">#{video_html}</div>"
        video_id=video_id[1..-1]
      end
      video_html.gsub(/VIDEO_ID/,video_id).gsub(/WIDTH/,width.to_s).gsub(/HEIGHT/,height.to_s)
    end

    desc "Embeds a photowidget flash presentation with the specified name. Expects to find that name as an xml file in the public/photowidget folder with appropriately configured content:\n\n" +
         "  !{{photowidget(awe)}}\n" +
         "  !{{photowidget(awe,600)}}\n" +
         "  !{{photowidget(awe,600,400)}}"
    macro :photowidget do |obj, args|
      photowidget_id = args.shift
      width = args.shift
      height = args.shift
      width ||= 400
      height ||= width
      puts "Have values photowidget:#{photowidget_id}, width:#{width}, height:#{height}"
      photowidget_html = '<div style="width:WIDTHpx;">\n' +
                         '  <object type="application/x-shockwave-flash" data="/photowidget/photowidget.swf" width="WIDTH" height="HEIGHT">\n' +
                         '    <param name="movie" value="/photowidget/photowidget.swf" />\n' +
                         '    <param name="bgcolor" value="#ffffff" />\n' +
                         '    <param name="AllowScriptAccess" value="always" />\n' +
                         '    <param name="flashvars" value="feed=/photowidget/PHOTOWIDGET_ID.xml" />\n' +
                         '    <p>This widget requires Flash Player 9 or better</p>\n' +
                         '  </object>\n' +
                         '</div>\n'
      photowidget_html.
        gsub(/WIDTH/,width.to_s).
        gsub(/HEIGHT/,height.to_s).
        gsub(/PHOTOWIDGET_ID/,photowidget_id.to_s).
        gsub(/\\n/,"\n")
      #Turn off this for a while as a test
      #''
    end

  end
end
