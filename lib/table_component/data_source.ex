defprotocol TableComponent.DataSource do
  @moduledoc """
  Protocol for data sources that can be used with the reusable table component.
  Schemas must implement this protocol to provide data for the table.
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
