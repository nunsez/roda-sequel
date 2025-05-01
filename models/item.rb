class Item < Sequel::Model(DB[:items])
  def to_json(_) = values.to_json
end
