class PropertyWrapper

  attr_reader :name, :type, :model, :sortable

  def initialize(opts = {})
    @name = (opts[:property] ? opts[:property].name : opts[:name]).to_sym
    @model = opts[:model]
    @type = opts[:type]
    @sortable = opts[:sortable] || false
  end

  def humanized_name
    @name.to_s.humanize.titleize rescue @name
  end

  def label
    @model.property_options[@name][:label] rescue humanized_name
  end

end
