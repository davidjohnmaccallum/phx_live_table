defmodule TableComponent.OrderItem do
  use Ecto.Schema
  import Ecto.Changeset

  schema "order_items" do
    field :product_name, :string
    field :quantity, :integer
    field :unit_price, :decimal
    field :total_price, :decimal

    belongs_to :order, TableComponent.Order

    timestamps()
  end

  @doc false
  def changeset(order_item, attrs) do
    order_item
    |> cast(attrs, [:product_name, :quantity, :unit_price, :total_price, :order_id])
    |> validate_required([:product_name, :quantity, :unit_price, :total_price])
    |> validate_number(:quantity, greater_than: 0)
    |> validate_number(:unit_price, greater_than_or_equal_to: 0)
    |> validate_number(:total_price, greater_than_or_equal_to: 0)
    |> foreign_key_constraint(:order_id)
  end
end
