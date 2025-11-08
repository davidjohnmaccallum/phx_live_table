defmodule TableComponentWeb.CustomersLive do
  use TableComponentWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def columns do
    [
      %{
        field: :name,
        label: "Name",
        sortable: true,
        search: true
      },
      %{
        field: :email,
        label: "Email",
        sortable: true,
        search: true
      },
      %{
        field: :phone,
        label: "Phone"
      },
      %{
        field: :company,
        label: "Company",
        sortable: true,
        search: true
      },
      %{
        field: :status,
        label: "Status",
        sortable: true,
        filterable: true,
        format: &String.capitalize/1
      }
    ]
  end
end
