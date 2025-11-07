defmodule TableComponentWeb.CustomersLive do
  use TableComponentWeb, :live_view
  alias TableComponent.{Customer, DataSource}

  @data_source %Customer.DataSource{}

  def mount(_params, _session, socket) do
    if connected?(socket) do
      total_count = DataSource.count(@data_source, [])
      customers = DataSource.list_paginated(@data_source, limit: 100, offset: 0)

      {:ok,
       socket
       |> assign(:page, 1)
       |> assign(:per_page, 100)
       |> assign(:has_more, length(customers) == 100)
       |> assign(:total_count, total_count)
       |> assign(:loaded_count, length(customers))
       |> assign(:sort_by, nil)
       |> assign(:sort_order, :asc)
       |> assign(:filters, %{})
       |> assign(:filter_modal, nil)
       |> assign(:filter_options, %{
         status: DataSource.filter_options(@data_source, :status)
       })
       |> stream(:customers, customers)}
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
       |> assign(:filters, %{})
       |> assign(:filter_modal, nil)
       |> assign(:filter_options, %{
         status: DataSource.filter_options(@data_source, :status)
       })
       |> stream(:customers, [])}
    end
  end

  def handle_event("load-more", _params, socket) do
    page = socket.assigns.page + 1
    per_page = socket.assigns.per_page
    offset = (page - 1) * per_page

    customers =
      DataSource.list_paginated(@data_source,
        limit: per_page,
        offset: offset,
        sort_by: socket.assigns.sort_by,
        sort_order: socket.assigns.sort_order,
        filters: socket.assigns.filters
      )

    has_more = length(customers) == per_page
    loaded_count = socket.assigns.loaded_count + length(customers)

    {:noreply,
     socket
     |> assign(:page, page)
     |> assign(:has_more, has_more)
     |> assign(:loaded_count, loaded_count)
     |> stream(:customers, customers)}
  end

  def handle_event("sort", %{"column" => column}, socket) do
    column_atom = String.to_existing_atom(column)
    current_sort_by = socket.assigns.sort_by
    current_sort_order = socket.assigns.sort_order

    {new_sort_by, new_sort_order} =
      cond do
        current_sort_by == column_atom && current_sort_order == :asc ->
          {column_atom, :desc}

        current_sort_by == column_atom && current_sort_order == :desc ->
          {nil, :asc}

        true ->
          {column_atom, :asc}
      end

    customers =
      DataSource.list_paginated(@data_source,
        limit: 100,
        offset: 0,
        sort_by: new_sort_by,
        sort_order: new_sort_order,
        filters: socket.assigns.filters
      )

    total_count = DataSource.count(@data_source, filters: socket.assigns.filters)

    {:noreply,
     socket
     |> assign(:page, 1)
     |> assign(:sort_by, new_sort_by)
     |> assign(:sort_order, new_sort_order)
     |> assign(:total_count, total_count)
     |> assign(:has_more, length(customers) == 100)
     |> assign(:loaded_count, length(customers))
     |> stream(:customers, customers, reset: true)}
  end

  def handle_event("open-filter-modal", %{"column" => column}, socket) do
    {:noreply, assign(socket, :filter_modal, String.to_existing_atom(column))}
  end

  def handle_event("close-filter-modal", _params, socket) do
    {:noreply, assign(socket, :filter_modal, nil)}
  end

  def handle_event("toggle-filter", %{"column" => column, "filter-value" => value}, socket) do
    column_atom = String.to_existing_atom(column)
    current_filters = socket.assigns.filters
    column_filters = Map.get(current_filters, column_atom, [])

    new_column_filters =
      if value in column_filters do
        List.delete(column_filters, value)
      else
        [value | column_filters]
      end

    new_filters = Map.put(current_filters, column_atom, new_column_filters)

    {:noreply, assign(socket, :filters, new_filters)}
  end

  def handle_event("apply-filters", _params, socket) do
    customers =
      DataSource.list_paginated(@data_source,
        limit: 100,
        offset: 0,
        sort_by: socket.assigns.sort_by,
        sort_order: socket.assigns.sort_order,
        filters: socket.assigns.filters
      )

    total_count = DataSource.count(@data_source, filters: socket.assigns.filters)

    {:noreply,
     socket
     |> assign(:page, 1)
     |> assign(:total_count, total_count)
     |> assign(:has_more, length(customers) == 100)
     |> assign(:loaded_count, length(customers))
     |> assign(:filter_modal, nil)
     |> stream(:customers, customers, reset: true)}
  end

  def handle_event("clear-filters", %{"column" => column}, socket) do
    column_atom = String.to_existing_atom(column)
    new_filters = Map.put(socket.assigns.filters, column_atom, [])

    customers =
      DataSource.list_paginated(@data_source,
        limit: 100,
        offset: 0,
        sort_by: socket.assigns.sort_by,
        sort_order: socket.assigns.sort_order,
        filters: new_filters
      )

    total_count = DataSource.count(@data_source, filters: new_filters)

    {:noreply,
     socket
     |> assign(:page, 1)
     |> assign(:filters, new_filters)
     |> assign(:total_count, total_count)
     |> assign(:has_more, length(customers) == 100)
     |> assign(:loaded_count, length(customers))
     |> assign(:filter_modal, nil)
     |> stream(:customers, customers, reset: true)}
  end

  def columns do
    [
      %{
        field: :name,
        label: "Name",
        sortable: true
      },
      %{
        field: :email,
        label: "Email",
        sortable: true
      },
      %{
        field: :phone,
        label: "Phone"
      },
      %{
        field: :company,
        label: "Company",
        sortable: true
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
