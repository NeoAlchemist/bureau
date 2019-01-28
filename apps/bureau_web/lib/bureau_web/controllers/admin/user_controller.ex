defmodule BureauWeb.AdminUserController do
  use BureauWeb, :controller
  alias Bureau.{Account, User}

  def index(conn, %{"search" => %{"username" => username}}) do
    list = Account.list(username: username, limit: 20)
    render(conn, "index.html", users: list)
  end

  def index(conn, _) do
    render(conn, "index.html", users: Account.list(order: :desc, limit: 20))
  end

  def update(conn, %{"id" => id, "user" => params}) do
    with {int, _} <- Integer.parse(id),
         {:ok, user} <- Account.update(int, params) do
      conn
      |> put_flash(:info, "Profile updated")
      |> render("show.html", user: user)
    else
      _ ->
        render(conn, "500.html")
    end
  end

  def show(conn, %{"id" => id}) do
    with {int, _} <- Integer.parse(id),
         %User{} = user <- Account.read(int) do
      conn
      |> render("show.html", user: user)
    else
      _ ->
        conn
        |> redirect(to: Routes.admin_user_path(conn, :index, []))
    end
  end

  def delete(conn, %{"id" => id}) do
    with {int, _} <- Integer.parse(id) do
      Account.delete(int)

      conn
      |> put_flash(:info, "Account deleted")
      |> redirect(to: Routes.admin_user_path(conn, :index, []))
    else
      _ ->
        conn
        |> redirect(to: Routes.admin_user_path(conn, :index, []))
    end
  end
end
