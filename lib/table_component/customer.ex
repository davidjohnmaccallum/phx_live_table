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
    search = Keyword.get(opts, :search, %{})

    query = from(c in __MODULE__)

    query = apply_filters(query, filters)
    query = apply_search(query, search)

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

  defp apply_search(query, search) do
    Enum.reduce(search, query, fn {column, term}, acc_query ->
      if term != "" do
        case column do
          :email ->
            search_pattern = "%#{term}%"
            from(c in acc_query, where: ilike(c.email, ^search_pattern))

          :name ->
            search_pattern = "%#{term}%"
            from(c in acc_query, where: ilike(c.name, ^search_pattern))

          :company ->
            search_pattern = "%#{term}%"
            from(c in acc_query, where: ilike(c.company, ^search_pattern))

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
    search = Keyword.get(opts, :search, %{})

    query = from(c in __MODULE__, select: count(c.id))
    query = apply_count_filters(query, filters)
    query = apply_count_search(query, search)
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

  defp apply_count_search(query, search) do
    Enum.reduce(search, query, fn {column, term}, acc_query ->
      if term != "" do
        case column do
          :email ->
            search_pattern = "%#{term}%"
            from(c in acc_query, where: ilike(c.email, ^search_pattern))

          :name ->
            search_pattern = "%#{term}%"
            from(c in acc_query, where: ilike(c.name, ^search_pattern))

          :company ->
            search_pattern = "%#{term}%"
            from(c in acc_query, where: ilike(c.company, ^search_pattern))

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

  @doc """
  Get available filter options for a specific column.
  Used by the DataSource protocol.
  """
  def filter_options(:status), do: available_statuses()
  def filter_options(_column), do: []
end
