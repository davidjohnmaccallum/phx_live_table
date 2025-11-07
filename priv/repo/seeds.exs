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

import Ecto.Query
alias TableComponent.Repo
alias TableComponent.{Customer, Order, OrderItem}

# Clear existing data
Repo.delete_all(OrderItem)
Repo.delete_all(Order)
Repo.delete_all(Customer)

IO.puts("Creating customers...")

# Create customers
customers = [
  %{
    name: "John Smith",
    email: "john.smith@example.com",
    phone: "+1-555-0101",
    company: "Tech Solutions Inc.",
    status: "active",
    address: "123 Main St, San Francisco, CA 94102"
  },
  %{
    name: "Sarah Johnson",
    email: "sarah.j@example.com",
    phone: "+1-555-0102",
    company: "Design Studio LLC",
    status: "active",
    address: "456 Oak Ave, New York, NY 10001"
  },
  %{
    name: "Michael Chen",
    email: "m.chen@example.com",
    phone: "+1-555-0103",
    company: "Global Trading Co.",
    status: "active",
    address: "789 Pine Rd, Austin, TX 78701"
  },
  %{
    name: "Emily Davis",
    email: "emily.davis@example.com",
    phone: "+1-555-0104",
    company: "Marketing Plus",
    status: "inactive",
    address: "321 Elm St, Seattle, WA 98101"
  },
  %{
    name: "Robert Wilson",
    email: "r.wilson@example.com",
    phone: "+1-555-0105",
    company: "Construction Partners",
    status: "active",
    address: "654 Maple Dr, Denver, CO 80201"
  },
  %{
    name: "Jennifer Martinez",
    email: "jen.martinez@example.com",
    phone: "+1-555-0106",
    company: "Healthcare Systems",
    status: "pending",
    address: "987 Cedar Ln, Boston, MA 02101"
  },
  %{
    name: "David Brown",
    email: "d.brown@example.com",
    phone: "+1-555-0107",
    company: "Consulting Group",
    status: "active",
    address: "147 Birch Way, Chicago, IL 60601"
  },
  %{
    name: "Lisa Anderson",
    email: "lisa.a@example.com",
    phone: "+1-555-0108",
    company: "Retail Solutions",
    status: "active",
    address: "258 Spruce St, Miami, FL 33101"
  },
  %{
    name: "James Taylor",
    email: "j.taylor@example.com",
    phone: "+1-555-0109",
    company: "Financial Services",
    status: "active",
    address: "369 Walnut Ave, Phoenix, AZ 85001"
  },
  %{
    name: "Maria Garcia",
    email: "maria.garcia@example.com",
    phone: "+1-555-0110",
    company: "Education Partners",
    status: "active",
    address: "741 Ash Blvd, Portland, OR 97201"
  },
  %{
    name: "Christopher Lee",
    email: "chris.lee@example.com",
    phone: "+1-555-0111",
    company: "Tech Innovations",
    status: "inactive",
    address: "852 Cypress Ct, Atlanta, GA 30301"
  },
  %{
    name: "Amanda White",
    email: "amanda.w@example.com",
    phone: "+1-555-0112",
    company: "Media Productions",
    status: "active",
    address: "963 Willow Rd, Las Vegas, NV 89101"
  }
]

inserted_customers = Enum.map(customers, fn customer_data ->
  {:ok, customer} =
    %Customer{}
    |> Customer.changeset(customer_data)
    |> Repo.insert()

  customer
end)

IO.puts("Created #{length(inserted_customers)} customers")

IO.puts("Creating orders...")

# Create orders for customers
orders_data = [
  # Orders for John Smith
  {0, "ORD-2024-001", "delivered", Decimal.new("1299.99"), ~D[2024-10-15], "Express delivery requested"},
  {0, "ORD-2024-015", "delivered", Decimal.new("599.50"), ~D[2024-10-28], nil},

  # Orders for Sarah Johnson
  {1, "ORD-2024-002", "shipped", Decimal.new("2450.00"), ~D[2024-10-16], "Gift wrap included"},
  {1, "ORD-2024-008", "processing", Decimal.new("899.99"), ~D[2024-10-22], nil},

  # Orders for Michael Chen
  {2, "ORD-2024-003", "processing", Decimal.new("5600.75"), ~D[2024-10-17], "Bulk order - warehouse delivery"},
  {2, "ORD-2024-012", "pending", Decimal.new("1200.00"), ~D[2024-10-26], nil},

  # Orders for Emily Davis (inactive customer)
  {3, "ORD-2024-004", "cancelled", Decimal.new("320.00"), ~D[2024-09-10], "Customer requested cancellation"},

  # Orders for Robert Wilson
  {4, "ORD-2024-005", "delivered", Decimal.new("4250.25"), ~D[2024-10-19], "Multiple items"},
  {4, "ORD-2024-013", "shipped", Decimal.new("750.00"), ~D[2024-10-27], nil},

  # Orders for Jennifer Martinez
  {5, "ORD-2024-006", "pending", Decimal.new("890.00"), ~D[2024-10-20], "Awaiting payment confirmation"},

  # Orders for David Brown
  {6, "ORD-2024-007", "delivered", Decimal.new("1750.50"), ~D[2024-10-21], nil},
  {6, "ORD-2024-016", "processing", Decimal.new("2100.00"), ~D[2024-10-29], nil},

  # Orders for Lisa Anderson
  {7, "ORD-2024-009", "shipped", Decimal.new("640.00"), ~D[2024-10-23], "Standard shipping"},

  # Orders for James Taylor
  {8, "ORD-2024-010", "delivered", Decimal.new("3200.00"), ~D[2024-10-24], "Priority order"},
  {8, "ORD-2024-017", "pending", Decimal.new("1500.00"), ~D[2024-10-30], nil},

  # Orders for Maria Garcia
  {9, "ORD-2024-011", "processing", Decimal.new("980.00"), ~D[2024-10-25], nil},

  # Orders for Amanda White
  {11, "ORD-2024-014", "delivered", Decimal.new("425.75"), ~D[2024-10-27], "Customer pickup"},
  {11, "ORD-2024-018", "shipped", Decimal.new("1850.00"), ~D[2024-10-31], nil}
]

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

# Create order items
order_items_data = [
  # Items for ORD-2024-001
  {0, "Laptop Computer", 1, "999.99", "999.99"},
  {0, "Wireless Mouse", 2, "49.99", "99.98"},
  {0, "USB-C Cable", 4, "15.00", "60.00"},
  {0, "Laptop Bag", 1, "89.99", "89.99"},
  {0, "Screen Protector", 1, "50.03", "50.03"},

  # Items for ORD-2024-002
  {2, "Office Chair", 2, "450.00", "900.00"},
  {2, "Desk Lamp", 3, "125.00", "375.00"},
  {2, "Monitor Stand", 5, "75.00", "375.00"},
  {2, "Ergonomic Keyboard", 4, "200.00", "800.00"},

  # Items for ORD-2024-003
  {4, "Server Hardware", 2, "2500.00", "5000.00"},
  {4, "Network Switch", 3, "200.25", "600.75"},

  # Items for ORD-2024-004
  {6, "Software License", 4, "80.00", "320.00"},

  # Items for ORD-2024-005
  {7, "Desktop Computer", 5, "850.05", "4250.25"},

  # Items for ORD-2024-006
  {9, "Tablet", 2, "445.00", "890.00"},

  # Items for ORD-2024-007
  {10, "Printer", 1, "550.00", "550.00"},
  {10, "Ink Cartridges", 12, "45.00", "540.00"},
  {10, "Paper Reams", 10, "8.50", "85.00"},
  {10, "Printer Stand", 1, "575.50", "575.50"},

  # Items for ORD-2024-008
  {3, "External Hard Drive", 3, "299.99", "899.97"},
  {3, "USB Flash Drive", 1, "0.02", "0.02"},

  # Items for ORD-2024-009
  {12, "Webcam", 4, "160.00", "640.00"},

  # Items for ORD-2024-010
  {13, "Projector", 2, "1600.00", "3200.00"},

  # Items for ORD-2024-011
  {15, "Headphones", 7, "140.00", "980.00"},

  # Items for ORD-2024-012
  {5, "Smartphone", 2, "600.00", "1200.00"},

  # Items for ORD-2024-013
  {8, "Smart Watch", 3, "250.00", "750.00"},

  # Items for ORD-2024-014
  {16, "Fitness Tracker", 5, "85.15", "425.75"},

  # Items for ORD-2024-015
  {1, "Bluetooth Speaker", 2, "149.99", "299.98"},
  {1, "Phone Case", 3, "29.99", "89.97"},
  {1, "Screen Cleaner Kit", 7, "14.99", "104.93"},
  {1, "Cable Organizer", 4, "26.15", "104.62"},

  # Items for ORD-2024-016
  {11, "Graphics Card", 1, "1200.00", "1200.00"},
  {11, "RAM Modules", 4, "150.00", "600.00"},
  {11, "Cooling Fan", 2, "150.00", "300.00"},

  # Items for ORD-2024-017
  {14, "Gaming Console", 1, "500.00", "500.00"},
  {14, "Controller", 4, "75.00", "300.00"},
  {14, "Game Titles", 10, "60.00", "600.00"},
  {14, "Charging Station", 1, "100.00", "100.00"},

  # Items for ORD-2024-018
  {17, "Camera", 1, "1200.00", "1200.00"},
  {17, "Camera Lens", 1, "450.00", "450.00"},
  {17, "Tripod", 1, "200.00", "200.00"}
]

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
