defmodule TableComponent.Repo.Migrations.CreateOrders do
  use Ecto.Migration

  def change do
    create table(:orders) do
      add :customer_id, references(:customers, on_delete: :delete_all), null: false
      add :order_number, :string, null: false
      add :status, :string, null: false, default: "pending"
      add :total_amount, :decimal, precision: 10, scale: 2, null: false
      add :order_date, :date, null: false
      add :notes, :text

      timestamps()
    end

    create unique_index(:orders, [:order_number])
    create index(:orders, [:customer_id])
    create index(:orders, [:status])
    create index(:orders, [:order_date])
  end
end
