# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     TableComponent.Repo.insert!(%TableComponent.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias TableComponent.Repo
alias TableComponent.{Customer, Order, OrderItem}

# Clear existing data
Repo.delete_all(OrderItem)
Repo.delete_all(Order)
Repo.delete_all(Customer)

IO.puts("Creating customers...")

# Create 200 customers for testing pagination with 1000 orders
customers = Enum.map(1..200, fn i ->
  statuses = ["active", "active", "active", "inactive", "pending"]
  companies = [
    "Tech Solutions Inc.", "Design Studio LLC", "Global Trading Co.",
    "Marketing Plus", "Construction Partners", "Healthcare Systems",
    "Consulting Group", "Retail Solutions", "Financial Services",
    "Education Partners", "Tech Innovations", "Media Productions",
    "Software Development", "Cloud Services", "Data Analytics",
    "E-commerce Platform", "Manufacturing Corp", "Logistics Company"
  ]

  countries = ["USA", "Canada", "UK", "Germany", "France", "Australia", "Japan", "Brazil"]
  cities = ["New York", "Los Angeles", "Chicago", "Toronto", "London", "Berlin", "Paris", "Sydney", "Tokyo", "São Paulo"]
  industries = ["Technology", "Healthcare", "Finance", "Retail", "Manufacturing", "Education", "Media", "Construction"]
  managers = ["Alice Johnson", "Bob Smith", "Carol Williams", "David Brown", "Emma Davis", "Frank Miller", "Grace Wilson"]

  %{
    name: "Customer #{i}",
    email: "customer#{i}@example.com",
    phone: "+1-555-#{String.pad_leading(to_string(1000 + i), 4, "0")}",
    company: Enum.random(companies),
    status: Enum.random(statuses),
    address: "#{i * 100} Business St, City, ST #{10000 + i}",
    country: Enum.random(countries),
    city: Enum.random(cities),
    postal_code: String.pad_leading(to_string(10000 + i), 5, "0"),
    website: "https://customer#{i}.example.com",
    industry: Enum.random(industries),
    employee_count: Enum.random([10, 25, 50, 100, 250, 500, 1000, 2500]),
    annual_revenue: Decimal.new(Enum.random(100_000..10_000_000)),
    account_manager: Enum.random(managers),
    last_contact_date: Date.add(Date.utc_today(), -Enum.random(1..365)),
    notes_count: Enum.random(0..50)
  }
end)

inserted_customers = Enum.map(customers, fn customer_data ->
  {:ok, customer} =
    %Customer{}
    |> Customer.changeset(customer_data)
    |> Repo.insert()

  customer
end)

IO.puts("Created #{length(inserted_customers)} customers")

IO.puts("Creating orders...")

# Create 1000 orders spread across customers
statuses = ["pending", "processing", "shipped", "delivered", "cancelled"]
orders_data = Enum.map(1..1000, fn i ->
  # Distribute orders across customers
  customer_index = rem(i - 1, length(inserted_customers))

  # Generate dates from the past 12 months
  days_ago = 365 - rem(i, 365)
  order_date = Date.add(Date.utc_today(), -days_ago)

  # Random amounts between $50 and $5000
  amount = Decimal.new("#{50 + :rand.uniform(4950)}.#{:rand.uniform(99)}")

  {
    customer_index,
    "ORD-2024-#{String.pad_leading(to_string(i), 5, "0")}",
    Enum.random(statuses),
    amount,
    order_date,
    if(rem(i, 3) == 0, do: "Note for order #{i}", else: nil)
  }
end)

inserted_orders = Enum.map(orders_data, fn {customer_idx, order_number, status, total_amount, order_date, notes} ->
  customer = Enum.at(inserted_customers, customer_idx)

  {:ok, order} =
    %Order{}
    |> Order.changeset(%{
      customer_id: customer.id,
      order_number: order_number,
      status: status,
      total_amount: total_amount,
      order_date: order_date,
      notes: notes
    })
    |> Repo.insert()

  order
end)

IO.puts("Created #{length(inserted_orders)} orders")

IO.puts("Creating order items...")

# Create 1-5 items for each order
product_names = [
  "Laptop Computer", "Wireless Mouse", "USB-C Cable", "Laptop Bag",
  "Office Chair", "Desk Lamp", "Monitor Stand", "Keyboard",
  "Server Hardware", "Network Switch", "Software License",
  "Desktop Computer", "Tablet", "Printer", "Ink Cartridges",
  "External Hard Drive", "USB Flash Drive", "Webcam", "Projector",
  "Headphones", "Smartphone", "Smart Watch", "Fitness Tracker",
  "Bluetooth Speaker", "Phone Case", "Graphics Card", "RAM Modules",
  "Gaming Console", "Controller", "Camera", "Camera Lens", "Tripod"
]

order_items_data = Enum.flat_map(0..(length(inserted_orders) - 1), fn order_idx ->
  # Each order has 1-5 items
  num_items = 1 + :rand.uniform(4)

  Enum.map(1..num_items, fn _ ->
    quantity = 1 + :rand.uniform(5)
    unit_price = Decimal.new("#{10 + :rand.uniform(990)}.#{:rand.uniform(99)}")
    total_price = Decimal.mult(unit_price, Decimal.new(quantity))

    {
      order_idx,
      Enum.random(product_names),
      quantity,
      Decimal.to_string(unit_price),
      Decimal.to_string(total_price)
    }
  end)
end)

inserted_order_items = Enum.map(order_items_data, fn {order_idx, product_name, quantity, unit_price, total_price} ->
  order = Enum.at(inserted_orders, order_idx)

  {:ok, order_item} =
    %OrderItem{}
    |> OrderItem.changeset(%{
      order_id: order.id,
      product_name: product_name,
      quantity: quantity,
      unit_price: Decimal.new(unit_price),
      total_price: Decimal.new(total_price)
    })
    |> Repo.insert()

  order_item
end)

IO.puts("Created #{length(inserted_order_items)} order items")

IO.puts("\n✅ Database seeded successfully!")
IO.puts("   - #{length(inserted_customers)} customers")
IO.puts("   - #{length(inserted_orders)} orders")
IO.puts("   - #{length(inserted_order_items)} order items")
