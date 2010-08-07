module Helpers
  
  def paging_links(page, count, qs = {})
    prev_link, next_link = 'Previous', 'Next'
    if not qs.blank?
      qs = qs.keys.collect{|k|
        [k,escape(qs[k])].join('=') if not qs[k].blank?
      }.compact.join('&')
      qs = nil if qs.blank?
    end
      
    if not page == 1
      prev_link = "<a href=\"?p=#{[page-1, qs].compact.join('&')}\" rel=\"previous\">#{prev_link}</a>"
    end
    if not page == count and count > 1
      next_link = "<a href=\"?p=#{[page+1, qs].compact.join('&')}\" rel=\"next\">#{next_link}</a>"
    end
    [prev_link, next_link]
  end

end
