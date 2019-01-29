defmodule BureauWeb.SessionController do
  use BureauWeb, :controller
  alias BureauWeb.SignIn

  plug :scrub_params, "sign_in" when action in [:create]

  def index(conn, _params) do
    with false <- Guardian.Plug.authenticated?(conn, []) do
      changeset = SignIn.verify()
      render(conn, "index.html", changeset: changeset, action: Routes.session_path(conn, :create))
    else
      _ ->
        conn
        |> redirect(to: Routes.page_path(conn, :index, []))
    end
  end

  def password(conn, _params) do
    with false <- Guardian.Plug.authenticated?(conn, []) do
      render(conn, "pswrd_reset.html",
        error: false,
        action: Routes.session_path(conn, :reset_pswrd)
      )
    else
      _ ->
        conn
        |> redirect(to: Routes.page_path(conn, :index, []))
    end
  end

  def reset_pswrd(conn, %{"reset" => %{"email" => email}}) do
    with true <- Regex.match?(~r/([\w-\.]+)@((?:[\w]+\.)+)([a-zA-Z]{2,4})/, email),
         user <- Bureau.Account.read(email: email),
         %Bamboo.Email{} <- BureauWeb.Email.send(conn, user, {:password, :reset_pswrd}) do
      conn
      |> put_flash(:info, "Welcome back #{user.username}")
      |> redirect(to: Routes.page_path(conn, :index, []))
    else
      _ ->
        render(conn, "pswrd_reset.html",
          error: true,
          action: Routes.session_path(conn, :reset_pswrd)
        )
    end
  end

  def create(conn, %{"sign_in" => params}) do
    with {:ok, user} <- SignIn.verify(params) do
      user
      |> BureauWeb.Authentication.authorize(conn)
      |> put_flash(:info, "Welcome back #{user.username}")
      |> redirect(to: Routes.page_path(conn, :index, []))
    else
      changeset ->
        render(conn, "index.html",
          changeset: %{changeset | action: :insert},
          action: Routes.session_path(conn, :create)
        )
    end
  end
end
