module Helpers
  
  def hash_to_qs(h)
    return nil if h.blank?
    qs = h.keys.collect{|k|
      [k,escape(h[k])].join('=') if not h[k].blank?
    }.compact.join('&')
    qs = nil if qs.blank?
    qs
  end

  def paging_links(page, count, qs = {})
    prev_link, next_link = 'Previous', 'Next'
    qs = hash_to_qs(qs)
      
    if not page == 1
      prev_link = "<a href=\"?p=#{[page-1, qs].compact.join('&')}\" rel=\"previous\">#{prev_link}</a>"
    end
    if not page == count and count > 1
      next_link = "<a href=\"?p=#{[page+1, qs].compact.join('&')}\" rel=\"next\">#{next_link}</a>"
    end
    [prev_link, next_link]
  end

  def column_head_link(property, current_order, qs = {})
    if property.sortable
      qs = hash_to_qs(qs)
      new_order = (current_order[0] == property.name ? (current_order[1] == :asc ? "desc" : "asc") : "asc")
      link_class = current_order[0] == property.name ? new_order : ''
      "<a href=\"?o=#{[(property.name.to_s+'.'+new_order.to_s),qs].compact.join('&')}\" class=\"#{link_class}\">#{property.label}</a>"
    else
      property.label
    end
  end

  def partial(template, options={})
    erb template, options.merge(:layout => false)
  end

  def logged_in?
    return true if not config[:auth_model] or not config[:sessions]
    config[:auth_model] and session[:user] and session[:user].authenticated?
  end

end
