class App < Roda
  plugin :json, classes: [Array, Hash, Sequel::Model]

  route do |r|
    r.root { "Hello, Roda!" }

    r.get "foo" do
      raise "123"
    end

    r.get "items" do
      items = Item.all
      { count: items.count, items: items.to_a }
    end
  end
end
