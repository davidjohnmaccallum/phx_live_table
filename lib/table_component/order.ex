defmodule TableComponent.Order do
  use Ecto.Schema
  import Ecto.Changeset

  schema "orders" do
    field :order_number, :string
    field :status, :string, default: "pending"
    field :total_amount, :decimal
    field :order_date, :date
    field :notes, :string

    belongs_to :customer, TableComponent.Customer
    has_many :order_items, TableComponent.OrderItem

    timestamps()
  end

  @doc false
  def changeset(order, attrs) do
    order
    |> cast(attrs, [:order_number, :status, :total_amount, :order_date, :notes, :customer_id])
    |> validate_required([:order_number, :status, :total_amount, :order_date])
    |> validate_inclusion(:status, ["pending", "processing", "shipped", "delivered", "cancelled"])
    |> validate_number(:total_amount, greater_than_or_equal_to: 0)
    |> unique_constraint(:order_number)
    |> foreign_key_constraint(:customer_id)
  end
end
