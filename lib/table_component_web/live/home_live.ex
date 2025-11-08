defmodule TableComponentWeb.HomeLive do
  use TableComponentWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def columns do
    [
      %{
        field: :order_number,
        label: "Order Number",
        sortable: true
      },
      %{
        field: :customer,
        label: "Customer",
        sortable: true,
        filterable: true,
        accessor: fn order -> order.customer.name end
      },
      %{
        field: :status,
        label: "Status",
        sortable: true,
        filterable: true,
        format: &String.capitalize/1
      },
      %{
        field: :order_date,
        label: "Order Date",
        sortable: true,
        format: fn date -> Calendar.strftime(date, "%Y-%m-%d") end
      },
      %{
        field: :total_amount,
        label: "Total Amount",
        sortable: true,
        align: :right,
        format: fn amount -> Decimal.to_string(amount) end
      }
    ]
  end
end
