defmodule TableComponent.OrderItem do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias TableComponent.Repo

  schema "order_items" do
    field :product_name, :string
    field :quantity, :integer
    field :unit_price, :decimal
    field :total_price, :decimal

    belongs_to :order, TableComponent.Order

    timestamps()
  end

  def changeset(order_item, attrs) do
    order_item
    |> cast(attrs, [:product_name, :quantity, :unit_price, :total_price, :order_id])
    |> validate_required([:product_name, :quantity, :unit_price, :total_price])
    |> validate_number(:quantity, greater_than: 0)
    |> validate_number(:unit_price, greater_than_or_equal_to: 0)
    |> validate_number(:total_price, greater_than_or_equal_to: 0)
    |> foreign_key_constraint(:order_id)
  end

  def list_paginated(opts \\ []) do
    limit = Keyword.get(opts, :limit, 20)
    offset = Keyword.get(opts, :offset, 0)
    sort_by = Keyword.get(opts, :sort_by)
    sort_order = Keyword.get(opts, :sort_order, :asc)
    filters = Keyword.get(opts, :filters, %{})
    order_id = Keyword.get(opts, :order_id)

    query = from(oi in __MODULE__)

    # Filter by order_id if provided
    query = if order_id do
      from(oi in query, where: oi.order_id == ^order_id)
    else
      query
    end

    # Apply additional filters
    query = apply_filters(query, filters)

    query =
      case sort_by do
        :product_name ->
          order_by(query, [oi], [{^sort_order, oi.product_name}, {^sort_order, oi.id}])

        :quantity ->
          order_by(query, [oi], [{^sort_order, oi.quantity}, {^sort_order, oi.id}])

        :unit_price ->
          order_by(query, [oi], [{^sort_order, oi.unit_price}, {^sort_order, oi.id}])

        :total_price ->
          order_by(query, [oi], [{^sort_order, oi.total_price}, {^sort_order, oi.id}])

        nil ->
          order_by(query, [oi], [asc: oi.id])
      end

    query
    |> limit(^limit)
    |> offset(^offset)
    |> Repo.all()
  end

  def count(opts \\ []) do
    filters = Keyword.get(opts, :filters, %{})
    order_id = Keyword.get(opts, :order_id)

    query = from(oi in __MODULE__)

    query = if order_id do
      from(oi in query, where: oi.order_id == ^order_id)
    else
      query
    end

    query = apply_filters(query, filters)

    Repo.aggregate(query, :count)
  end

  def filter_options(column) do
    from(oi in __MODULE__, select: field(oi, ^column), distinct: true)
    |> Repo.all()
    |> Enum.reject(&is_nil/1)
  end

  defp apply_filters(query, filters) do
    Enum.reduce(filters, query, fn {column, values}, acc_query ->
      if values != [] do
        from(oi in acc_query, where: field(oi, ^column) in ^values)
      else
        acc_query
      end
    end)
  end
end
