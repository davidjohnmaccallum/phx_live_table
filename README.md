# TableComponent

A reusable, data table component for Phoenix LiveView with sorting, filtering, searching, and infinite scroll capabilities.

## Features

- ✨ **Infinite Scroll** - Smooth, performant pagination using LiveView streams
- 🔍 **Column Search** - Real-time search on individual columns
- 🎯 **Multi-Column Filtering** - Filter by multiple values per column
- ⬆️⬇️ **Sortable Columns** - Click to sort, click again to reverse, click third time to clear
- 🎨 **Customizable Formatting** - Format cell values with custom functions
- 📱 **Responsive Design** - Built with Tailwind CSS for mobile-friendly tables
- ⚡ **High Performance** - Handles large datasets efficiently with LiveView streams

## Quick Start

To start your Phoenix server:

* Run `mix setup` to install and setup dependencies
* Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## Usage

### 1. Define Your Schema

Your schema needs to implement three functions to work with the DataTable component:

```elixir
defmodule MyApp.Customer do
  use Ecto.Schema
  import Ecto.Query
  alias MyApp.Repo

  schema "customers" do
    field :name, :string
    field :email, :string
    field :company, :string
    field :status, :string
    timestamps()
  end

  # Required: List paginated records with optional sorting, filtering, and search
  def list_paginated(opts \\ []) do
    limit = Keyword.get(opts, :limit, 20)
    offset = Keyword.get(opts, :offset, 0)
    sort_by = Keyword.get(opts, :sort_by)
    sort_order = Keyword.get(opts, :sort_order, :asc)
    filters = Keyword.get(opts, :filters, %{})
    search = Keyword.get(opts, :search, %{})

    query = from(c in __MODULE__)
    
    # Apply filters
    query = Enum.reduce(filters, query, fn {column, values}, acc ->
      if values != [] do
        from(c in acc, where: field(c, ^column) in ^values)
      else
        acc
      end
    end)
    
    # Apply search
    query = Enum.reduce(search, query, fn {column, term}, acc ->
      if term != "" do
        search_pattern = "%#{term}%"
        from(c in acc, where: ilike(field(c, ^column), ^search_pattern))
      else
        acc
      end
    end)
    
    # Apply sorting
    query = if sort_by do
      order_by(query, [c], [{^sort_order, field(c, ^sort_by)}])
    else
      query
    end

    query
    |> limit(^limit)
    |> offset(^offset)
    |> Repo.all()
  end

  # Required: Count total records with filters and search
  def count(opts \\ []) do
    filters = Keyword.get(opts, :filters, %{})
    search = Keyword.get(opts, :search, %{})

    query = from(c in __MODULE__)
    
    query = Enum.reduce(filters, query, fn {column, values}, acc ->
      if values != [] do
        from(c in acc, where: field(c, ^column) in ^values)
      else
        acc
      end
    end)
    
    query = Enum.reduce(search, query, fn {column, term}, acc ->
      if term != "" do
        search_pattern = "%#{term}%"
        from(c in acc, where: ilike(field(c, ^column), ^search_pattern))
      else
        acc
      end
    end)

    Repo.aggregate(query, :count)
  end

  # Optional: Return available filter options for a column
  def filter_options(column) do
    from(c in __MODULE__, select: field(c, ^column), distinct: true)
    |> Repo.all()
    |> Enum.reject(&is_nil/1)
  end
end
```

### 2. Create a LiveView

```elixir
defmodule MyAppWeb.CustomersLive do
  use MyAppWeb, :live_view

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
        field: :company,
        label: "Company",
        sortable: true,
        filterable: true
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
```

### 3. Add the Template

```heex
<Layouts.app flash={@flash}>
  <div class="flex h-screen">
    <div class="flex-1 flex flex-col">
      <div class="px-6 py-4 border-b border-zinc-300 bg-white">
        <h1 class="text-2xl font-semibold text-zinc-900">Customers</h1>
      </div>
      
      <.live_component
        module={TableComponentWeb.Components.DataTable}
        id="customers"
        data_module={MyApp.Customer}
        stream_name={:customers}
        columns={columns()}
        on_row_click="customer-clicked"
      />
    </div>
  </div>
</Layouts.app>
```

### 4. Handle Row Clicks (Optional)

If you want to respond to row clicks, add a `handle_info/2` callback in your LiveView:

```elixir
def handle_info({"customer-clicked", id}, socket) do
  # Navigate to customer detail page, open a modal, etc.
  {:noreply, push_navigate(socket, to: ~p"/customers/#{id}")}
end
```

## Column Options

Each column in the `columns/0` function supports the following options:

| Option | Type | Required | Description |
|--------|------|----------|-------------|
| `:field` | `atom` | ✅ | The field name in your schema |
| `:label` | `string` | ✅ | Display label for the column header |
| `:sortable` | `boolean` | ❌ | Enable sorting (default: `false`) |
| `:filterable` | `boolean` | ❌ | Enable filtering with multi-select (default: `false`) |
| `:search` | `boolean` | ❌ | Enable text search (default: `false`) |
| `:accessor` | `function/1` | ❌ | Custom function to get value from record (default: `&Map.get(&1, field)`) |
| `:format` | `function/1` | ❌ | Custom function to format display value (default: `&to_string/1`) |
| `:align` | `atom` | ❌ | Text alignment: `:left`, `:right`, or `:center` (default: `:left`) |
| `:class` | `string` or `function/1` | ❌ | Additional CSS classes for the cell |

### Column Examples

```elixir
# Basic column
%{field: :name, label: "Name"}

# Sortable and searchable
%{
  field: :email,
  label: "Email",
  sortable: true,
  search: true
}

# With custom formatting
%{
  field: :price,
  label: "Price",
  sortable: true,
  align: :right,
  format: fn val -> "$#{Number.Delimit.number_to_delimited(val, precision: 2)}" end
}

# With filtering
%{
  field: :status,
  label: "Status",
  sortable: true,
  filterable: true,
  format: &String.capitalize/1
}

# With custom accessor and formatting
%{
  field: :created_at,
  label: "Created",
  sortable: true,
  accessor: fn record -> record.inserted_at end,
  format: fn datetime -> Calendar.strftime(datetime, "%Y-%m-%d %H:%M") end
}

# With conditional CSS classes
%{
  field: :status,
  label: "Status",
  class: fn record ->
    case record.status do
      "active" -> "text-green-600 font-semibold"
      "inactive" -> "text-red-600"
      _ -> "text-gray-600"
    end
  end
}
```

## Component Props

The `DataTable` live component accepts the following props:

| Prop | Type | Required | Description |
| Prop | Type | Required | Description |
|------|------|----------|-------------|
| `id` | `string` | ✅ | Unique identifier for the component |
| `data_module` | `module` | ✅ | Your schema module (e.g., `MyApp.Customer`) |
| `stream_name` | `atom` | ✅ | Name for the LiveView stream (e.g., `:customers`) |
| `columns` | `list` | ✅ | List of column definitions |
| `on_row_click` | `string` | ❌ | Event name to send to parent when row is clicked |

## How It Works

### LiveView Streams

The component uses LiveView streams for optimal performance with large datasets. Streams allow the table to efficiently update the DOM by only adding/removing/updating the changed rows rather than re-rendering the entire table.

### Infinite Scroll

As users scroll to the bottom of the table, the component automatically loads the next batch of records. The default page size is 100 records per load.

### Row Click Handler

When a user clicks on a table row, the component sends a message to the parent LiveView if `on_row_click` is specified. The message format is `{event_name, record_id}`, which you can handle in your LiveView's `handle_info/2` callback.

Example:
```elixir
# In template
<.live_component on_row_click="customer-clicked" ... />

# In LiveView
def handle_info({"customer-clicked", id}, socket) do
  {:noreply, push_navigate(socket, to: ~p"/customers/#{id}")}
end
```

### Sorting

Click a sortable column header to:
1. First click: Sort ascending
2. Second click: Sort descending  
3. Third click: Clear sorting (return to default order)

### Filtering

Filterable columns show a filter icon. Clicking opens a modal where users can select multiple values. The table updates in real-time as selections change.

### Searching

Searchable columns show a search icon. Clicking opens a search input. The search is case-insensitive and uses SQL `ILIKE` for pattern matching.

## Advanced Example

Here's a more comprehensive example with formatted numbers, dates, and conditional styling:

```elixir
def columns do
  [
    %{
      field: :name,
      label: "Customer Name",
      sortable: true,
      search: true,
      class: "font-medium"
    },
    %{
      field: :employee_count,
      label: "Employees",
      sortable: true,
      align: :right,
      format: fn val -> 
        if val, 
          do: Number.Delimit.number_to_delimited(val, precision: 0), 
          else: "-" 
      end
    },
    %{
      field: :annual_revenue,
      label: "Annual Revenue",
      sortable: true,
      align: :right,
      format: fn val -> 
        if val, 
          do: "$#{Number.Delimit.number_to_delimited(val, precision: 0)}", 
          else: "-" 
      end
    },
    %{
      field: :last_contact_date,
      label: "Last Contact",
      sortable: true,
      format: fn val -> 
        if val, 
          do: Calendar.strftime(val, "%Y-%m-%d"), 
          else: "-" 
      end
    },
    %{
      field: :status,
      label: "Status",
      sortable: true,
      filterable: true,
      format: &String.capitalize/1,
      class: fn record ->
        case record.status do
          "active" -> "text-green-700 bg-green-50 px-2 py-1 rounded"
          "inactive" -> "text-red-700 bg-red-50 px-2 py-1 rounded"
          _ -> "text-gray-700 bg-gray-50 px-2 py-1 rounded"
        end
      end
    }
  ]
end
```

## Customization

The component uses Tailwind CSS classes and can be customized by modifying the template in `lib/table_component_web/components/data_table.html.heex`.

Key customization points:
- Table header styling
- Row hover effects
- Icon appearance
- Modal dialogs
- Loading states
- Empty states

## Performance Tips

1. **Index your sortable and filterable columns** in the database for faster queries
2. **Limit the number of columns** with search enabled to reduce query complexity
3. **Use custom accessors** sparingly as they can't leverage database indexes
4. **Adjust page size** based on your data complexity (default is 100 rows per page)

## Learn More

* Official Phoenix website: https://www.phoenixframework.org/
* Phoenix LiveView docs: https://hexdocs.pm/phoenix_live_view
* Tailwind CSS: https://tailwindcss.com/
