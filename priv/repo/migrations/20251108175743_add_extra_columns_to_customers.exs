defmodule TableComponent.Repo.Migrations.AddExtraColumnsToCustomers do
  use Ecto.Migration

  def change do
    alter table(:customers) do
      add :country, :string
      add :city, :string
      add :postal_code, :string
      add :website, :string
      add :industry, :string
      add :employee_count, :integer
      add :annual_revenue, :decimal
      add :account_manager, :string
      add :last_contact_date, :date
      add :notes_count, :integer
    end
  end
end
