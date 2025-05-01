class User < Sequel::Model(DB[:users])
  def to_json(_) = values.to_json
end
