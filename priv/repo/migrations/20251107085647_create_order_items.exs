defmodule TableComponent.Repo.Migrations.CreateOrderItems do
  use Ecto.Migration

  def change do
    create table(:order_items) do
      add :order_id, references(:orders, on_delete: :delete_all), null: false
      add :product_name, :string, null: false
      add :quantity, :integer, null: false
      add :unit_price, :decimal, precision: 10, scale: 2, null: false
      add :total_price, :decimal, precision: 10, scale: 2, null: false

      timestamps()
    end

    create index(:order_items, [:order_id])
  end
end
