defmodule TableComponentWeb.OrdersLive do
  use TableComponentWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_info({"order-clicked", id}, socket) do
    {:noreply, push_navigate(socket, to: ~p"/orders/#{id}/items")}
  end

  def columns do
    [
      %{
        field: :order_number,
        label: "Order Number",
        sortable: true,
        class: "font-mono font-bold text-blue-600"
      },
      %{
        field: :customer,
        label: "Customer",
        sortable: true,
        filterable: true,
        # Accessor: Navigate through associations to get nested data
        accessor: fn order -> order.customer.name end
      },
      %{
        field: :customer_email,
        label: "Email",
        # Accessor: Get data from nested association
        accessor: fn order -> order.customer.email end
      },
      %{
        field: :status,
        label: "Status",
        sortable: true,
        filterable: true,
        format: &String.capitalize/1,
        class: fn order ->
          case order.status do
            "shipped" -> "font-semibold text-green-700 bg-green-50"
            "pending" -> "font-semibold text-yellow-700 bg-yellow-50"
            "cancelled" -> "font-semibold text-red-700 bg-red-50"
            "delivered" -> "font-semibold text-blue-700 bg-blue-50"
            _ -> "font-semibold"
          end
        end
      },
      %{
        field: :order_date,
        label: "Order Date",
        sortable: true,
        format: fn date -> Calendar.strftime(date, "%Y-%m-%d") end,
        class: "font-mono text-zinc-600"
      },
      %{
        field: :total_amount,
        label: "Total Amount",
        sortable: true,
        align: :right,
        format: fn val -> if val, do: Number.Delimit.number_to_delimited(val, precision: 2), else: "-" end,
        class: fn order ->
          amount = Decimal.to_float(order.total_amount)
          cond do
            amount >= 3000 -> "bg-blue-900 text-zinc-100"
            amount >= 2500 -> "bg-blue-800 text-zinc-100"
            amount >= 2000 -> "bg-blue-700 text-zinc-100"
            amount >= 1500 -> "bg-blue-600 text-zinc-100"
            amount >= 1000 -> "bg-blue-500 text-zinc-100"
            amount >= 500 -> "bg-blue-400 text-zinc-100"
            true -> "bg-blue-300 text-zinc-900"
          end
        end
      }
    ]
  end
end
