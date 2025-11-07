defmodule TableComponentWeb.HomeLive do
  use TableComponentWeb, :live_view
  alias TableComponent.Order

  def mount(_params, _session, socket) do
    if connected?(socket) do
      total_count = Order.count()
      orders = Order.list_paginated(limit: 100, offset: 0)

      {:ok,
       socket
       |> assign(:page, 1)
       |> assign(:per_page, 100)
       |> assign(:has_more, length(orders) == 100)
       |> assign(:total_count, total_count)
       |> assign(:loaded_count, length(orders))
       |> assign(:sort_by, nil)
       |> assign(:sort_order, :asc)
       |> stream(:orders, orders)}
    else
      {:ok,
       socket
       |> assign(:page, 1)
       |> assign(:per_page, 100)
       |> assign(:has_more, true)
       |> assign(:total_count, 0)
       |> assign(:loaded_count, 0)
       |> assign(:sort_by, nil)
       |> assign(:sort_order, :asc)
       |> stream(:orders, [])}
    end
  end

  def handle_event("load-more", _params, socket) do
    page = socket.assigns.page + 1
    per_page = socket.assigns.per_page
    offset = (page - 1) * per_page

    orders =
      Order.list_paginated(
        limit: per_page,
        offset: offset,
        sort_by: socket.assigns.sort_by,
        sort_order: socket.assigns.sort_order
      )

    has_more = length(orders) == per_page
    loaded_count = socket.assigns.loaded_count + length(orders)

    {:noreply,
     socket
     |> assign(:page, page)
     |> assign(:has_more, has_more)
     |> assign(:loaded_count, loaded_count)
     |> stream(:orders, orders)}
  end

  def handle_event("sort", %{"column" => column}, socket) do
    column_atom = String.to_existing_atom(column)
    current_sort_by = socket.assigns.sort_by
    current_sort_order = socket.assigns.sort_order

    {new_sort_by, new_sort_order} =
      cond do
        # Clicking the same column - cycle through asc -> desc -> nil
        current_sort_by == column_atom && current_sort_order == :asc ->
          {column_atom, :desc}

        current_sort_by == column_atom && current_sort_order == :desc ->
          {nil, :asc}

        # Clicking a different column - start with asc
        true ->
          {column_atom, :asc}
      end

    # Reload data from beginning with new sort
    orders =
      Order.list_paginated(
        limit: 100,
        offset: 0,
        sort_by: new_sort_by,
        sort_order: new_sort_order
      )

    {:noreply,
     socket
     |> assign(:page, 1)
     |> assign(:sort_by, new_sort_by)
     |> assign(:sort_order, new_sort_order)
     |> assign(:has_more, length(orders) == 100)
     |> assign(:loaded_count, length(orders))
     |> stream(:orders, orders, reset: true)}
  end

  defp sort_icon(column, sort_by, sort_order) do
    cond do
      sort_by == column && sort_order == :asc -> "↑"
      sort_by == column && sort_order == :desc -> "↓"
      true -> ""
    end
  end
end
