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
        field: :country,
        label: "Country",
        sortable: true
      },
      %{
        field: :city,
        label: "City",
        sortable: true
      },
      %{
        field: :postal_code,
        label: "Postal Code"
      },
      %{
        field: :website,
        label: "Website"
      },
      %{
        field: :industry,
        label: "Industry",
        sortable: true
      },
      %{
        field: :employee_count,
        label: "Employees",
        sortable: true,
        align: :right,
        format: fn val -> if val, do: Number.Delimit.number_to_delimited(val, precision: 0), else: "-" end
      },
      %{
        field: :annual_revenue,
        label: "Annual Revenue",
        sortable: true,
        align: :right,
        format: fn val -> if val, do: "$#{Number.Delimit.number_to_delimited(val, precision: 0)}", else: "-" end
      },
      %{
        field: :account_manager,
        label: "Account Manager",
        sortable: true
      },
      %{
        field: :last_contact_date,
        label: "Last Contact",
        sortable: true,
        format: fn val -> if val, do: Calendar.strftime(val, "%Y-%m-%d"), else: "-" end
      },
      %{
        field: :notes_count,
        label: "Notes",
        sortable: true,
        align: :right
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
