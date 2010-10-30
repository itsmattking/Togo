module Helpers
  
  class FlashHash
    def initialize
      @h = {}
      @c = {}
    end
    def [](key)
      return @c[key] if @c.keys.include?(key)
      @c[key] = @h.delete(key) if @h.keys.include?(key)
    end
    def []=(key,val)
      @h[key] = val
    end
    def sweep!
      @c = {}
    end
  end

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
    qs = hash_to_qs(qs)
    new_order = (current_order[0] == property.name.to_sym ? (current_order[1] == :asc ? "desc" : "asc") : "asc")
    link_class = current_order[0] == property.name.to_sym ? new_order : ''
    "<a href=\"?o=#{[(property.name.to_s+'.'+new_order.to_s),qs].compact.join('&')}\" class=\"#{link_class}\">#{property.name.to_s.humanize.titleize}</a>"
  end

  def partial(template, options={})
    erb template, options.merge(:layout => false)
  end

  def active_menu(name)
    request.path =~ /#{name}/ ? 'active' : ''
  end

end
