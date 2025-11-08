defmodule TableComponentWeb.Components.FilterModal do
  use Phoenix.Component
  import TableComponentWeb.CoreComponents

  @doc """
  Renders a filter modal for table columns.

  ## Attributes
    * `column` - Required. The column name (atom or string)
    * `filter_options` - Required. List of available filter options
    * `selected_filters` - Required. List of currently selected filters
    * `on_close` - Required. Event name to close the modal
    * `on_toggle` - Required. Event name to toggle a filter
    * `on_clear` - Required. Event name to clear all filters
    * `on_apply` - Required. Event name to apply filters
    * `target` - Required. The target component for events
  """
  attr :column, :any, required: true
  attr :filter_options, :list, required: true
  attr :selected_filters, :list, required: true
  attr :on_close, :string, required: true
  attr :on_toggle, :string, required: true
  attr :on_clear, :string, required: true
  attr :on_apply, :string, required: true
  attr :target, :any, required: true

  def filter_modal(assigns) do
    ~H"""
    <div class="fixed inset-0 z-50">
      <div
        phx-hook="FilterModal"
        id="filter-modal"
        data-column={@column}
        class="fixed bg-white rounded-lg shadow-lg border border-zinc-300 w-64 flex flex-col max-h-96"
        phx-window-keydown={@on_close}
        phx-key="escape"
        phx-click-away={@on_close}
        phx-target={@target}
      >
        <div class="flex items-center justify-between px-4 py-2 border-b border-zinc-200 flex-shrink-0">
          <h3 class="text-sm font-semibold text-zinc-900 capitalize">
            Filter by {@column |> to_string() |> String.replace("_", " ")}
          </h3>
          <button
            type="button"
            phx-click={@on_close}
            phx-target={@target}
            class="text-zinc-400 hover:text-zinc-600"
          >
            <.icon name="hero-x-mark" class="w-4 h-4" />
          </button>
        </div>

        <div class="px-4 py-2 overflow-y-auto flex-1">
          <div class="space-y-1">
            <div :for={option <- @filter_options} class="flex items-center">
              <label class="flex items-center cursor-pointer w-full py-1 px-2 rounded hover:bg-zinc-50">
                <input
                  type="checkbox"
                  checked={option in @selected_filters}
                  phx-click={@on_toggle}
                  phx-value-column={@column}
                  phx-value-filter-value={option}
                  phx-target={@target}
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
            phx-click={@on_clear}
            phx-value-column={@column}
            phx-target={@target}
            class="px-3 py-1 text-xs font-medium text-zinc-700 hover:text-zinc-900"
          >
            Clear All
          </button>
          <div class="flex gap-2">
            <button
              type="button"
              phx-click={@on_close}
              phx-target={@target}
              class="px-3 py-1 text-xs font-medium text-zinc-700 bg-zinc-100 rounded hover:bg-zinc-200"
            >
              Cancel
            </button>
            <button
              type="button"
              phx-click={@on_apply}
              phx-target={@target}
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
end
