defmodule TableComponent.Customer do
  use Ecto.Schema
  import Ecto.Changeset

  schema "customers" do
    field :name, :string
    field :email, :string
    field :phone, :string
    field :company, :string
    field :status, :string, default: "active"
    field :address, :string

    has_many :orders, TableComponent.Order

    timestamps()
  end

  def changeset(customer, attrs) do
    customer
    |> cast(attrs, [:name, :email, :phone, :company, :status, :address])
    |> validate_required([:name, :email, :status])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/, message: "must have the @ sign and no spaces")
    |> validate_inclusion(:status, ["active", "inactive", "pending"])
    |> unique_constraint(:email)
  end
end
