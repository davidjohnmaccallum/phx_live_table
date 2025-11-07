defprotocol TableComponent.DataSource do
  @moduledoc """
  Protocol for data sources that can be used with the reusable table component.

  Instead of implementing this protocol for each schema, schemas should implement
  the required functions (`list_paginated/1`, `count/1`, `filter_options/1`) directly,
  and this protocol will dispatch to them automatically when you pass the module atom.

  ## Usage

      # In your LiveView
      @data_source TableComponent.Order

      # The protocol automatically dispatches to Order.list_paginated/1
      DataSource.list_paginated(@data_source, opts)
  """

  @doc """
  List paginated records with optional filters and sorting.

  ## Options
    * `:limit` - Maximum number of records to return (default: 20)
    * `:offset` - Number of records to skip (default: 0)
    * `:sort_by` - Column to sort by (atom)
    * `:sort_order` - Sort direction (:asc or :desc)
    * `:filters` - Map of column filters %{column_atom => [values]}
  """
  @spec list_paginated(t(), keyword()) :: [struct()]
  def list_paginated(data, opts)

  @doc """
  Count total records with optional filters.

  ## Options
    * `:filters` - Map of column filters %{column_atom => [values]}
  """
  @spec count(t(), keyword()) :: non_neg_integer()
  def count(data, opts)

  @doc """
  Get available filter options for a specific column.
  Returns a list of unique values that can be used to filter.
  """
  @spec filter_options(t(), atom()) :: [term()]
  def filter_options(data, column)
end

defimpl TableComponent.DataSource, for: Atom do
  @moduledoc """
  Generic protocol implementation for module atoms.

  This allows any module that implements the required functions to work
  as a data source without needing to define wrapper structs or
  per-module protocol implementations.
  """

  def list_paginated(module, opts) when is_atom(module) do
    module.list_paginated(opts)
  end

  def count(module, opts) when is_atom(module) do
    module.count(opts)
  end

  def filter_options(module, column) when is_atom(module) do
    if function_exported?(module, :filter_options, 1) do
      module.filter_options(column)
    else
      []
    end
  end
end
