defmodule TableComponent.Repo do
  use Ecto.Repo,
    otp_app: :table_component,
    adapter: Ecto.Adapters.Postgres
end
