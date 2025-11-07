defmodule TableComponentWeb.Components.DataTable do
  use Phoenix.Component
  import TableComponentWeb.CoreComponents

  @doc """
  Renders a data table with sorting, filtering, and infinite scroll.

  ## Attributes
    * `id` - Required. Unique ID for the table
    * `stream` - Required. LiveView stream containing the data
    * `columns` - Required. List of column definitions
    * `sort_by` - Current sort column (atom)
    * `sort_order` - Current sort order (:asc or :desc)
    * `filters` - Map of active filters %{column => [values]}
    * `filter_modal` - Currently open filter modal column (atom or nil)
    * `filter_options` - Map of available filter options %{column => [values]}
    * `total_count` - Total number of records
    * `loaded_count` - Number of loaded records
    * `has_more` - Whether more records are available
    * `page` - Current page number

  ## Column Definition
    * `:field` - Required. Field name (atom)
    * `:label` - Required. Display label (string)
    * `:sortable` - Whether column is sortable (boolean, default: false)
    * `:filterable` - Whether column is filterable (boolean, default: false)
    * `:accessor` - Function to get value from record (default: &Map.get(&1, field))
    * `:format` - Function to format value for display (default: &to_string/1)
    * `:align` - Text alignment (:left, :right, :center, default: :left)
    * `:class` - Additional CSS classes
  """
  attr :id, :string, required: true
  attr :stream, :any, required: true
  attr :columns, :list, required: true
  attr :sort_by, :atom, default: nil
  attr :sort_order, :atom, default: :asc
  attr :filters, :map, default: %{}
  attr :filter_modal, :atom, default: nil
  attr :filter_options, :map, default: %{}
  attr :total_count, :integer, required: true
  attr :loaded_count, :integer, required: true
  attr :has_more, :boolean, default: false
  attr :page, :integer, default: 1

  def data_table(assigns) do
    ~H"""
    <div class="flex-1 flex flex-col overflow-hidden pb-10">
      <table class="w-full border-collapse bg-white" id={"#{@id}-table"} phx-hook="ResizableTable">
        <thead class="bg-zinc-100 sticky top-0 z-10">
          <tr>
            <th
              :for={column <- @columns}
              class={[
                "px-3 py-2 text-left text-xs font-semibold text-zinc-700 uppercase tracking-wider border-r border-b border-zinc-300 relative group",
                last_column?(column, @columns) && "border-r-0"
              ]}
            >
              <div class="flex items-center justify-between gap-2">
                <%= if column[:sortable] do %>
                  <button
                    type="button"
                    phx-click="sort"
                    phx-value-column={column.field}
                    class="flex items-center gap-1 hover:text-blue-600 flex-1"
                  >
                    {column.label}
                    <span class="text-blue-600 font-bold">{sort_icon(column.field, @sort_by, @sort_order)}</span>
                  </button>
                <% else %>
                  <span>{column.label}</span>
                <% end %>

                <%= if column[:filterable] do %>
                  <button
                    type="button"
                    id={"filter-button-#{column.field}"}
                    phx-click="open-filter-modal"
                    phx-value-column={column.field}
                    class={[
                      "p-1 rounded hover:bg-zinc-200",
                      has_active_filters?(@filters, column.field) && "bg-blue-500 text-white hover:bg-blue-600"
                    ]}
                  >
                    <.icon name="hero-funnel" class="w-3 h-3" />
                  </button>
                <% end %>
              </div>
              <%= if !last_column?(column, @columns) do %>
                <div class="absolute top-0 right-0 w-1 h-full cursor-col-resize hover:bg-blue-500 resize-handle"></div>
              <% end %>
            </th>
          </tr>
        </thead>
        <tbody id={@id} phx-update="stream">
          <tr
            :for={{dom_id, record} <- @stream}
            id={dom_id}
            class="border-b border-zinc-200 hover:bg-blue-50 cursor-pointer"
          >
            <td
              :for={column <- @columns}
              class={[
                "px-3 py-2 text-sm text-zinc-900 border-r border-zinc-200 whitespace-nowrap overflow-hidden text-ellipsis",
                last_column?(column, @columns) && "border-r-0",
                text_align_class(column[:align] || :left)
              ]}
            >
              {format_cell_value(record, column)}
            </td>
          </tr>
        </tbody>
      </table>
      <div :if={@has_more} id={"#{@id}-infinite-scroll-marker"} phx-hook="InfiniteScroll" data-page={@page}></div>
    </div>

    <div class="fixed bottom-0 left-64 right-0 bg-zinc-50 border-t border-zinc-300 px-6 py-2 text-sm text-zinc-700">
      Record count: {Number.Delimit.number_to_delimited(@total_count, precision: 0)} Showing: {Number.Delimit.number_to_delimited(@loaded_count, precision: 0)}
    </div>

    <%!-- Filter Modal --%>
    <div
      :if={@filter_modal != nil}
      class="fixed inset-0 z-50"
    >
      <div
        phx-hook="FilterModal"
        id="filter-modal"
        data-column={@filter_modal}
        class="fixed bg-white rounded-lg shadow-lg border border-zinc-300 w-64 flex flex-col max-h-96"
        phx-window-keydown="close-filter-modal"
        phx-key="escape"
        phx-click-away="close-filter-modal"
      >
        <div class="flex items-center justify-between px-4 py-2 border-b border-zinc-200 flex-shrink-0">
          <h3 class="text-sm font-semibold text-zinc-900 capitalize">Filter by {@filter_modal |> to_string() |> String.replace("_", " ")}</h3>
          <button
            type="button"
            phx-click="close-filter-modal"
            class="text-zinc-400 hover:text-zinc-600"
          >
            <.icon name="hero-x-mark" class="w-4 h-4" />
          </button>
        </div>

        <div class="px-4 py-2 overflow-y-auto flex-1">
          <div class="space-y-1">
            <div :for={option <- get_filter_options(@filter_options, @filter_modal)} class="flex items-center">
              <label class="flex items-center cursor-pointer w-full py-1 px-2 rounded hover:bg-zinc-50">
                <input
                  type="checkbox"
                  checked={option in get_column_filters(@filters, @filter_modal)}
                  phx-click="toggle-filter"
                  phx-value-column={@filter_modal}
                  phx-value-filter-value={option}
                  class="w-4 h-4 text-blue-600 border-zinc-300 rounded focus:ring-blue-500"
                />
                <span class="ml-2 text-sm text-zinc-900 capitalize">{option}</span>
              </label>
            </div>
          </div>
        </div>

        <div class="flex items-center justify-between gap-2 px-4 py-2 border-t border-zinc-200 flex-shrink-0">
          <button
            type="button"
            phx-click="clear-filters"
            phx-value-column={@filter_modal}
            class="px-3 py-1 text-xs font-medium text-zinc-700 hover:text-zinc-900"
          >
            Clear All
          </button>
          <div class="flex gap-2">
            <button
              type="button"
              phx-click="close-filter-modal"
              class="px-3 py-1 text-xs font-medium text-zinc-700 bg-zinc-100 rounded hover:bg-zinc-200"
            >
              Cancel
            </button>
            <button
              type="button"
              phx-click="apply-filters"
              class="px-3 py-1 text-xs font-medium text-white bg-blue-600 rounded hover:bg-blue-700"
            >
              Apply
            </button>
          </div>
        </div>
      </div>
    </div>
    """
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
