defmodule TableComponentWeb.PageController do
  use TableComponentWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
