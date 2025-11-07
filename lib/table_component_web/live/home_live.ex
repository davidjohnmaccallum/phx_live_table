defmodule TableComponentWeb.HomeLive do
  use TableComponentWeb, :live_view
  alias TableComponent.Order

  def mount(_params, _session, socket) do
    orders = Order.list()
    {:ok, assign(socket, orders: orders)}
  end

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <div class="h-full flex flex-col">
        <div class="p-6">
          <h1 class="text-2xl font-semibold text-zinc-900">
            Orders
          </h1>
        </div>

        <div class="flex-1 overflow-auto bg-white" phx-hook="ResizableTable" id="resizable-table">
          <table class="border-collapse" style="table-layout: fixed;">
            <thead class="sticky top-0 bg-zinc-100 border-b border-zinc-300">
              <tr>
                <th
                  class="relative px-3 py-2 text-left text-xs font-semibold text-zinc-700 border-r border-zinc-300 whitespace-nowrap"
                  style="width: 150px;"
                >
                  Order Number
                  <div class="absolute top-0 right-0 w-1 h-full cursor-col-resize hover:bg-blue-500 resize-handle"></div>
                </th>
                <th
                  class="relative px-3 py-2 text-left text-xs font-semibold text-zinc-700 border-r border-zinc-300 whitespace-nowrap"
                  style="width: 200px;"
                >
                  Customer
                  <div class="absolute top-0 right-0 w-1 h-full cursor-col-resize hover:bg-blue-500 resize-handle"></div>
                </th>
                <th
                  class="relative px-3 py-2 text-left text-xs font-semibold text-zinc-700 border-r border-zinc-300 whitespace-nowrap"
                  style="width: 120px;"
                >
                  Status
                  <div class="absolute top-0 right-0 w-1 h-full cursor-col-resize hover:bg-blue-500 resize-handle"></div>
                </th>
                <th
                  class="relative px-3 py-2 text-left text-xs font-semibold text-zinc-700 border-r border-zinc-300 whitespace-nowrap"
                  style="width: 150px;"
                >
                  Order Date
                  <div class="absolute top-0 right-0 w-1 h-full cursor-col-resize hover:bg-blue-500 resize-handle"></div>
                </th>
                <th
                  class="relative px-3 py-2 text-left text-xs font-semibold text-zinc-700 whitespace-nowrap"
                  style="width: 150px;"
                >
                  Total Amount
                  <div class="absolute top-0 right-0 w-1 h-full cursor-col-resize hover:bg-blue-500 resize-handle"></div>
                </th>
              </tr>
            </thead>
            <tbody>
              <tr
                :for={order <- @orders}
                class="border-b border-zinc-200 hover:bg-blue-50 cursor-default"
              >
                <td class="px-3 py-2 text-sm text-zinc-900 border-r border-zinc-200 whitespace-nowrap overflow-hidden text-ellipsis">
                  {order.order_number}
                </td>
                <td class="px-3 py-2 text-sm text-zinc-900 border-r border-zinc-200 whitespace-nowrap overflow-hidden text-ellipsis">
                  {order.customer.name}
                </td>
                <td class="px-3 py-2 text-sm text-zinc-900 border-r border-zinc-200 whitespace-nowrap overflow-hidden text-ellipsis">
                  {order.status}
                </td>
                <td class="px-3 py-2 text-sm text-zinc-600 border-r border-zinc-200 whitespace-nowrap overflow-hidden text-ellipsis">
                  {Calendar.strftime(order.order_date, "%Y-%m-%d")}
                </td>
                <td class="px-3 py-2 text-sm text-zinc-900 text-right whitespace-nowrap overflow-hidden text-ellipsis">
                  {Decimal.to_string(order.total_amount)}
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </Layouts.app>
    """
  end
end
