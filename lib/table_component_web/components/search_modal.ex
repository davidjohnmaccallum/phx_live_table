defmodule TableComponentWeb.Components.SearchModal do
  use Phoenix.Component
  import TableComponentWeb.CoreComponents

  @doc """
  Renders a search modal for table columns.

  ## Attributes
    * `column` - Required. The column name (atom or string)
    * `search_term` - Required. The current search term
    * `on_close` - Required. Event name to close the modal
    * `on_search` - Required. Event name to handle search input
    * `on_clear` - Required. Event name to clear search
    * `on_apply` - Required. Event name to apply search
    * `target` - Required. The target component for events
  """
  attr :column, :any, required: true
  attr :search_term, :string, required: true
  attr :on_close, :string, required: true
  attr :on_search, :string, required: true
  attr :on_clear, :string, required: true
  attr :on_apply, :string, required: true
  attr :target, :any, required: true

  def search_modal(assigns) do
    ~H"""
    <div class="fixed inset-0 z-50">
      <div
        phx-hook="SearchModal"
        id="search-modal"
        data-column={@column}
        class="fixed bg-white rounded-lg shadow-lg border border-zinc-300 w-80 flex flex-col"
        phx-window-keydown={@on_close}
        phx-key="escape"
        phx-click-away={@on_close}
        phx-target={@target}
      >
        <div class="flex items-center justify-between px-4 py-2 border-b border-zinc-200">
          <h3 class="text-sm font-semibold text-zinc-900 capitalize">
            Search {@column |> to_string() |> String.replace("_", " ")}
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

        <div class="px-4 py-4">
          <div class="relative">
            <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
              <.icon name="hero-magnifying-glass" class="w-4 h-4 text-zinc-400" />
            </div>
            <input
              type="text"
              name="search_input"
              value={@search_term}
              phx-keyup={@on_search}
              phx-value-column={@column}
              phx-target={@target}
              phx-debounce="300"
              placeholder="Type to search..."
              class="block w-full pl-10 pr-3 py-2 border border-zinc-300 rounded-lg text-sm focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
              autofocus
            />
          </div>
          <p class="mt-2 text-xs text-zinc-500">
            Press Enter or click Apply to search
          </p>
        </div>

        <div class="flex items-center justify-between gap-2 px-4 py-2 border-t border-zinc-200">
          <button
            type="button"
            phx-click={@on_clear}
            phx-value-column={@column}
            phx-target={@target}
            class="px-3 py-1 text-xs font-medium text-zinc-700 hover:text-zinc-900"
          >
            Clear
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
