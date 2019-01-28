defmodule BureauWeb.PageController do
  use BureauWeb, :controller
  alias Bureau.{Account, Offer}

  def index(conn, _params) do
    conn
    |> put_status(:ok)
    |> render("index.html", latest: %{users: Account.latest(), jobs: Offer.latest()})
  end

  def not_found(conn, _params) do
    conn
    |> put_status(:not_found)
    |> render("404.html", layout: {BureauWeb.LayoutView, "errors.html"})
  end
end
