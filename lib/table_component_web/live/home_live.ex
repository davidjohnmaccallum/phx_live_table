defmodule TableComponentWeb.HomeLive do
  use TableComponentWeb, :live_view
  alias TableComponent.Order

  def mount(_params, _session, socket) do
    if connected?(socket) do
      total_count = Order.count()
      orders = Order.list_paginated(limit: 20, offset: 0)

      {:ok,
       socket
       |> assign(:page, 1)
       |> assign(:per_page, 20)
       |> assign(:has_more, length(orders) == 20)
       |> assign(:total_count, total_count)
       |> assign(:loaded_count, length(orders))
       |> stream(:orders, orders)}
    else
      {:ok,
       socket
       |> assign(:page, 1)
       |> assign(:per_page, 20)
       |> assign(:has_more, true)
       |> assign(:total_count, 0)
       |> assign(:loaded_count, 0)
       |> stream(:orders, [])}
    end
  end

  def handle_event("load-more", _params, socket) do
    page = socket.assigns.page + 1
    per_page = socket.assigns.per_page
    offset = (page - 1) * per_page

    orders = Order.list_paginated(limit: per_page, offset: offset)
    has_more = length(orders) == per_page
    loaded_count = socket.assigns.loaded_count + length(orders)

    {:noreply,
     socket
     |> assign(:page, page)
     |> assign(:has_more, has_more)
     |> assign(:loaded_count, loaded_count)
     |> stream(:orders, orders)}
  end
end
