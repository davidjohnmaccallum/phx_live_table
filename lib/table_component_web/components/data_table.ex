defmodule TableComponentWeb.Components.DataTable do
  use TableComponentWeb, :live_component
  alias TableComponent.DataSource
  import TableComponentWeb.Components.FilterModal
  import TableComponentWeb.Components.SearchModal

  @doc """
  Renders a data table with sorting, filtering, searching, and infinite scroll.

  ## Attributes
    * `id` - Required. Unique ID for the table
    * `data_module` - Required. Module containing the data (e.g., Order, Customer)
    * `columns` - Required. List of column definitions
    * `stream_name` - Required. Name of the stream (atom, e.g., :orders)

  ## Column Definition
    * `:field` - Required. Field name (atom)
    * `:label` - Required. Display label (string)
    * `:sortable` - Whether column is sortable (boolean, default: false)
    * `:filterable` - Whether column is filterable (boolean, default: false)
    * `:search` - Whether column is searchable (boolean, default: false)
    * `:accessor` - Function to get value from record (default: &Map.get(&1, field))
    * `:format` - Function to format value for display (default: &to_string/1)
    * `:align` - Text alignment (:left, :right, :center, default: :left)
    * `:class` - Additional CSS classes
  """

  def update(assigns, socket) do
    socket =
      if connected?(socket) do
        data_module = assigns.data_module
        stream_name = assigns.stream_name

        # Get filter options for filterable columns
        filter_options =
          assigns.columns
          |> Enum.filter(& &1[:filterable])
          |> Enum.map(fn col -> {col.field, DataSource.filter_options(data_module, col.field)} end)
          |> Enum.into(%{})

        total_count = DataSource.count(data_module, [])
        records = DataSource.list_paginated(data_module, limit: 100, offset: 0)

        socket
        |> assign(assigns)
        |> assign(:page, 1)
        |> assign(:per_page, 100)
        |> assign(:has_more, length(records) == 100)
        |> assign(:total_count, total_count)
        |> assign(:loaded_count, length(records))
        |> assign(:sort_by, nil)
        |> assign(:sort_order, :asc)
        |> assign(:filters, %{})
        |> assign(:open_filter_column, nil)
        |> assign(:filter_options, filter_options)
        |> assign(:open_search_column, nil)
        |> assign(:search_terms, %{})
        |> assign(:pending_search_term, "")
        |> stream(stream_name, records)
      else
        socket
        |> assign(assigns)
        |> assign(:page, 1)
        |> assign(:per_page, 100)
        |> assign(:has_more, true)
        |> assign(:total_count, 0)
        |> assign(:loaded_count, 0)
        |> assign(:sort_by, nil)
        |> assign(:sort_order, :asc)
        |> assign(:filters, %{})
        |> assign(:open_filter_column, nil)
        |> assign(:filter_options, %{})
        |> assign(:open_search_column, nil)
        |> assign(:search_terms, %{})
        |> assign(:pending_search_term, "")
        |> stream(assigns.stream_name, [])
      end

    {:ok, socket}
  end

  def handle_event("load-more", _params, socket) do
    page = socket.assigns.page + 1
    per_page = socket.assigns.per_page
    offset = (page - 1) * per_page

    records =
      DataSource.list_paginated(socket.assigns.data_module,
        limit: per_page,
        offset: offset,
        sort_by: socket.assigns.sort_by,
        sort_order: socket.assigns.sort_order,
        filters: socket.assigns.filters,
        search: socket.assigns.search_terms
      )

    has_more = length(records) == per_page
    loaded_count = socket.assigns.loaded_count + length(records)

    {:noreply,
     socket
     |> assign(:page, page)
     |> assign(:has_more, has_more)
     |> assign(:loaded_count, loaded_count)
     |> stream(socket.assigns.stream_name, records)}
  end

  def handle_event("sort", %{"column" => column}, socket) do
    column_atom = String.to_existing_atom(column)
    current_sort_by = socket.assigns.sort_by
    current_sort_order = socket.assigns.sort_order

    {new_sort_by, new_sort_order} =
      cond do
        current_sort_by == column_atom && current_sort_order == :asc ->
          {column_atom, :desc}

        current_sort_by == column_atom && current_sort_order == :desc ->
          {nil, :asc}

        true ->
          {column_atom, :asc}
      end

    records =
      DataSource.list_paginated(socket.assigns.data_module,
        limit: 100,
        offset: 0,
        sort_by: new_sort_by,
        sort_order: new_sort_order,
        filters: socket.assigns.filters,
        search: socket.assigns.search_terms
      )

    total_count =
      DataSource.count(socket.assigns.data_module,
        filters: socket.assigns.filters,
        search: socket.assigns.search_terms
      )

    {:noreply,
     socket
     |> assign(:page, 1)
     |> assign(:sort_by, new_sort_by)
     |> assign(:sort_order, new_sort_order)
     |> assign(:total_count, total_count)
     |> assign(:has_more, length(records) == 100)
     |> assign(:loaded_count, length(records))
     |> stream(socket.assigns.stream_name, records, reset: true)}
  end

  def handle_event("open-filter-modal", %{"column" => column}, socket) do
    {:noreply, assign(socket, :open_filter_column, String.to_existing_atom(column))}
  end

  def handle_event("close-filter-modal", _params, socket) do
    {:noreply, assign(socket, :open_filter_column, nil)}
  end

  def handle_event("toggle-filter", %{"column" => column, "filter-value" => value}, socket) do
    column_atom = String.to_existing_atom(column)
    current_filters = socket.assigns.filters
    column_filters = Map.get(current_filters, column_atom, [])

    new_column_filters =
      if value in column_filters do
        List.delete(column_filters, value)
      else
        [value | column_filters]
      end

    new_filters = Map.put(current_filters, column_atom, new_column_filters)

    {:noreply, assign(socket, :filters, new_filters)}
  end

  def handle_event("apply-filters", _params, socket) do
    records =
      DataSource.list_paginated(socket.assigns.data_module,
        limit: 100,
        offset: 0,
        sort_by: socket.assigns.sort_by,
        sort_order: socket.assigns.sort_order,
        filters: socket.assigns.filters,
        search: socket.assigns.search_terms
      )

    total_count =
      DataSource.count(socket.assigns.data_module,
        filters: socket.assigns.filters,
        search: socket.assigns.search_terms
      )

    {:noreply,
     socket
     |> assign(:page, 1)
     |> assign(:total_count, total_count)
     |> assign(:has_more, length(records) == 100)
     |> assign(:loaded_count, length(records))
     |> assign(:open_filter_column, nil)
     |> stream(socket.assigns.stream_name, records, reset: true)}
  end

  def handle_event("clear-filters", %{"column" => column}, socket) do
    column_atom = String.to_existing_atom(column)
    new_filters = Map.put(socket.assigns.filters, column_atom, [])

    records =
      DataSource.list_paginated(socket.assigns.data_module,
        limit: 100,
        offset: 0,
        sort_by: socket.assigns.sort_by,
        sort_order: socket.assigns.sort_order,
        filters: new_filters,
        search: socket.assigns.search_terms
      )

    total_count =
      DataSource.count(socket.assigns.data_module,
        filters: new_filters,
        search: socket.assigns.search_terms
      )

    {:noreply,
     socket
     |> assign(:page, 1)
     |> assign(:filters, new_filters)
     |> assign(:total_count, total_count)
     |> assign(:has_more, length(records) == 100)
     |> assign(:loaded_count, length(records))
     |> assign(:open_filter_column, nil)
     |> stream(socket.assigns.stream_name, records, reset: true)}
  end

  def handle_event("open-search-modal", %{"column" => column}, socket) do
    column_atom = String.to_existing_atom(column)
    current_search = Map.get(socket.assigns.search_terms, column_atom, "")

    socket =
      socket
      |> assign(:open_search_column, column_atom)
      |> assign(:pending_search_term, current_search)

    {:noreply, socket}
  end

  def handle_event("close-search-modal", _params, socket) do
    {:noreply, assign(socket, :open_search_column, nil)}
  end

  def handle_event("update-search", %{"key" => "Enter", "value" => value}, socket) do
    # When Enter is pressed, update the value and apply the search
    socket =
      socket
      |> assign(:pending_search_term, value)

    handle_event("apply-search", %{}, socket)
  end

  def handle_event("update-search", %{"value" => value}, socket) do
    {:noreply, assign(socket, :pending_search_term, value)}
  end

  def handle_event("apply-search", _params, socket) do
    column = socket.assigns.open_search_column
    search_term = socket.assigns.pending_search_term

    new_search_terms =
      if search_term == "" do
        Map.delete(socket.assigns.search_terms, column)
      else
        Map.put(socket.assigns.search_terms, column, search_term)
      end

    records =
      DataSource.list_paginated(socket.assigns.data_module,
        limit: 100,
        offset: 0,
        sort_by: socket.assigns.sort_by,
        sort_order: socket.assigns.sort_order,
        filters: socket.assigns.filters,
        search: new_search_terms
      )

    total_count =
      DataSource.count(socket.assigns.data_module,
        filters: socket.assigns.filters,
        search: new_search_terms
      )

    {:noreply,
     socket
     |> assign(:page, 1)
     |> assign(:search_terms, new_search_terms)
     |> assign(:total_count, total_count)
     |> assign(:has_more, length(records) == 100)
     |> assign(:loaded_count, length(records))
     |> assign(:open_search_column, nil)
     |> stream(socket.assigns.stream_name, records, reset: true)}
  end

  def handle_event("clear-search", %{"column" => _column}, socket) do
    new_search_terms = Map.delete(socket.assigns.search_terms, socket.assigns.open_search_column)

    records =
      DataSource.list_paginated(socket.assigns.data_module,
        limit: 100,
        offset: 0,
        sort_by: socket.assigns.sort_by,
        sort_order: socket.assigns.sort_order,
        filters: socket.assigns.filters,
        search: new_search_terms
      )

    total_count =
      DataSource.count(socket.assigns.data_module,
        filters: socket.assigns.filters,
        search: new_search_terms
      )

    {:noreply,
     socket
     |> assign(:page, 1)
     |> assign(:search_terms, new_search_terms)
     |> assign(:pending_search_term, "")
     |> assign(:total_count, total_count)
     |> assign(:has_more, length(records) == 100)
     |> assign(:loaded_count, length(records))
     |> assign(:open_search_column, nil)
     |> stream(socket.assigns.stream_name, records, reset: true)}
  end

  defp sort_icon(column, current_sort, order) do
    cond do
      current_sort == column and order == :asc -> "↑"
      current_sort == column and order == :desc -> "↓"
      true -> ""
    end
  end

  defp has_active_filters?(filters, column) when is_atom(column) do
    case Map.get(filters, column) do
      nil -> false
      [] -> false
      _list -> true
    end
  end

  defp has_active_search?(search_terms, column) when is_atom(column) do
    case Map.get(search_terms, column) do
      nil -> false
      "" -> false
      _term -> true
    end
  end

  defp get_filter_options(filter_options, column) when is_atom(column) do
    Map.get(filter_options, column, [])
  end

  defp get_column_filters(filters, column) when is_atom(column) do
    Map.get(filters, column, [])
  end

  defp last_column?(column, columns) do
    List.last(columns) == column
  end

  defp text_align_class(:left), do: "text-left"
  defp text_align_class(:right), do: "text-right"
  defp text_align_class(:center), do: "text-center"
  defp text_align_class(_), do: "text-left"

  defp format_cell_value(record, column) do
    accessor = column[:accessor] || fn r -> Map.get(r, column.field) end
    formatter = column[:format] || (&to_string/1)

    record
    |> accessor.()
    |> formatter.()
  end
end
