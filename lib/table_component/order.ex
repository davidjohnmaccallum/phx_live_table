defmodule TableComponent.Order do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias TableComponent.Repo

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

  def changeset(order, attrs) do
    order
    |> cast(attrs, [:order_number, :status, :total_amount, :order_date, :notes, :customer_id])
    |> validate_required([:order_number, :status, :total_amount, :order_date])
    |> validate_inclusion(:status, ["pending", "processing", "shipped", "delivered", "cancelled"])
    |> validate_number(:total_amount, greater_than_or_equal_to: 0)
    |> unique_constraint(:order_number)
    |> foreign_key_constraint(:customer_id)
  end

  def list do
    __MODULE__
    |> preload(:customer)
    |> Repo.all()
  end

  def list_paginated(opts \\ []) do
    limit = Keyword.get(opts, :limit, 20)
    offset = Keyword.get(opts, :offset, 0)
    sort_by = Keyword.get(opts, :sort_by)
    sort_order = Keyword.get(opts, :sort_order, :asc)
    filters = Keyword.get(opts, :filters, %{})

    query = from(o in __MODULE__, preload: :customer)

    # Apply filters dynamically
    query = apply_filters(query, filters)

    query =
      case sort_by do
        :order_number ->
          order_by(query, [o], [{^sort_order, o.order_number}, {^sort_order, o.id}])

        :customer ->
          query
          |> join(:left, [o], c in assoc(o, :customer))
          |> order_by([o, c], [{^sort_order, c.name}, {^sort_order, o.id}])

        :status ->
          order_by(query, [o], [{^sort_order, o.status}, {^sort_order, o.id}])

        :order_date ->
          order_by(query, [o], [{^sort_order, o.order_date}, {^sort_order, o.id}])

        :total_amount ->
          order_by(query, [o], [{^sort_order, o.total_amount}, {^sort_order, o.id}])

        nil ->
          order_by(query, [o], [desc: o.order_date, desc: o.id])
      end

    query
    |> limit(^limit)
    |> offset(^offset)
    |> Repo.all()
  end

  defp apply_filters(query, filters) do
    require Logger
    Logger.debug("Applying filters: #{inspect(filters)}")

    Enum.reduce(filters, query, fn {column, values}, acc_query ->
      if values != [] do
        Logger.debug("Filtering #{column} with values: #{inspect(values)}")

        case column do
          :status ->
            from(o in acc_query, where: o.status in ^values)

          :customer ->
            from(o in acc_query,
              join: c in assoc(o, :customer),
              where: c.name in ^values
            )

          _ ->
            acc_query
        end
      else
        acc_query
      end
    end)
  end

  def count(opts \\ []) do
    filters = Keyword.get(opts, :filters, %{})

    query = from(o in __MODULE__)

    query = apply_count_filters(query, filters)

    Repo.aggregate(query, :count)
  end

  defp apply_count_filters(query, filters) do
    Enum.reduce(filters, query, fn {column, values}, acc_query ->
      if values != [] do
        case column do
          :status ->
            from(o in acc_query, where: o.status in ^values)

          :customer ->
            from(o in acc_query,
              join: c in assoc(o, :customer),
              where: c.name in ^values
            )

          _ ->
            acc_query
        end
      else
        acc_query
      end
    end)
  end

  def available_statuses do
    ["pending", "processing", "shipped", "delivered", "cancelled"]
  end

  def available_customers do
    alias TableComponent.Customer

    Customer
    |> order_by([c], c.name)
    |> Repo.all()
    |> Enum.map(& &1.name)
  end
end

defimpl TableComponent.DataSource, for: Atom do
  alias TableComponent.Order

  def list_paginated(Order, opts) do
    Order.list_paginated(opts)
  end

  def count(Order, opts) do
    Order.count(opts)
  end

  def filter_options(Order, :status) do
    Order.available_statuses()
  end

  def filter_options(Order, :customer) do
    Order.available_customers()
  end

  def filter_options(Order, _column) do
    []
  end
end
