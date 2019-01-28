defmodule BureauWeb.AdminSessionController do
  use BureauWeb, :controller

  def index(conn, _params) do
    with %{"typ" => "admin"} <- Guardian.Plug.current_claims(conn) do
      redirect(conn, to: Routes.dashboard_path(conn, :index, []))
    else
      _ ->
        conn
        |> render("index.html", action: Routes.admin_session_path(conn, :create))
    end
  end

  def create(conn, params) do
    with {:ok, admin} <- Bureau.Admin.authorized(params) do
      admin
      |> BureauWeb.Authentication.authorize(conn)
      |> put_flash(:info, "Welcome Admin #{admin.username}")
      |> redirect(to: Routes.dashboard_path(conn, :index, []))
    else
      _ ->
        conn
        |> render("index.html", action: Routes.admin_session_path(conn, :create))
    end
  end

  def delete(conn, _params) do
    conn
    |> Guardian.Plug.sign_out(BureauWeb.Guardian, [])
    |> put_flash(:info, "Signed out successfully")
    |> redirect(to: Routes.admin_session_path(conn, :index, []))
  end
end
