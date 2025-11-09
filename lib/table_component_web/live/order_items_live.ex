defmodule TableComponentWeb.OrderItemsLive do
  use TableComponentWeb, :live_view

  def mount(%{"id" => order_id}, _session, socket) do
    {:ok, assign(socket, :order_id, String.to_integer(order_id))}
  end

  def columns do
    [
      %{
        field: :product_name,
        label: "Product",
        sortable: true
      },
      %{
        field: :quantity,
        label: "Quantity",
        sortable: true,
        align: :right
      },
      %{
        field: :unit_price,
        label: "Unit Price",
        sortable: true,
        align: :right,
        format: fn val -> "#{Number.Delimit.number_to_delimited(val, precision: 2)}" end
      },
      %{
        field: :total_price,
        label: "Total",
        sortable: true,
        align: :right,
        format: fn val -> "#{Number.Delimit.number_to_delimited(val, precision: 2)}" end,
        class: "font-semibold"
      }
    ]
  end
end
