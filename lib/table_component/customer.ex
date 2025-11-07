defmodule TableComponent.Customer do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias TableComponent.Repo

  schema "customers" do
    field :name, :string
    field :email, :string
    field :phone, :string
    field :company, :string
    field :status, :string, default: "active"
    field :address, :string

    has_many :orders, TableComponent.Order

    timestamps()
  end

  def changeset(customer, attrs) do
    customer
    |> cast(attrs, [:name, :email, :phone, :company, :status, :address])
    |> validate_required([:name, :email, :status])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/, message: "must have the @ sign and no spaces")
    |> validate_inclusion(:status, ["active", "inactive", "pending"])
    |> unique_constraint(:email)
  end

  def list_paginated(opts \\ []) do
    limit = Keyword.get(opts, :limit, 20)
    offset = Keyword.get(opts, :offset, 0)
    sort_by = Keyword.get(opts, :sort_by)
    sort_order = Keyword.get(opts, :sort_order, :asc)
    filters = Keyword.get(opts, :filters, %{})

    query = from(c in __MODULE__)

    query = apply_filters(query, filters)

    query =
      case sort_by do
        :name ->
          order_by(query, [c], [{^sort_order, c.name}, {^sort_order, c.id}])

        :email ->
          order_by(query, [c], [{^sort_order, c.email}, {^sort_order, c.id}])

        :company ->
          order_by(query, [c], [{^sort_order, c.company}, {^sort_order, c.id}])

        :status ->
          order_by(query, [c], [{^sort_order, c.status}, {^sort_order, c.id}])

        nil ->
          order_by(query, [c], [asc: c.name, asc: c.id])
      end

    query
    |> limit(^limit)
    |> offset(^offset)
    |> Repo.all()
  end

  defp apply_filters(query, filters) do
    Enum.reduce(filters, query, fn {column, values}, acc_query ->
      if values != [] do
        case column do
          :status ->
            from(c in acc_query, where: c.status in ^values)

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

    query = from(c in __MODULE__, select: count(c.id))
    query = apply_count_filters(query, filters)
    Repo.one(query)
  end

  defp apply_count_filters(query, filters) do
    Enum.reduce(filters, query, fn {column, values}, acc_query ->
      if values != [] do
        case column do
          :status ->
            from(c in acc_query, where: c.status in ^values)

          _ ->
            acc_query
        end
      else
        acc_query
      end
    end)
  end

  def available_statuses do
    ["active", "inactive", "pending"]
  end
end

defmodule TableComponent.Customer.DataSource do
  @moduledoc """
  DataSource wrapper for Customer queries
  """
  defstruct []

  defimpl TableComponent.DataSource do
    alias TableComponent.Customer

    def list_paginated(_source, opts) do
      Customer.list_paginated(opts)
    end

    def count(_source, opts) do
      Customer.count(opts)
    end

    def filter_options(_source, :status) do
      Customer.available_statuses()
    end

    def filter_options(_source, _column) do
      []
    end
  end
end
