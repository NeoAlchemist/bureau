defmodule BureauWeb.UserController do
  use BureauWeb, :controller
  alias Bureau.{Account, User}

  plug :scrub_params, "user" when action in [:create]

  def index(conn, %{"search" => %{"username" => username}}) do
    list = Account.list(like: {:username, username}, verified: true, limit: 10)
    render(conn, "index.html", users: list)
  end

  def index(conn, _) do
    render(conn, "index.html", users: Account.list(verified: true, limit: 10))
  end

  def create(conn, %{"user" => params}) do
    with {:ok, user} <- Account.create(params),
         %Bamboo.Email{} <- BureauWeb.Email.send(conn, user, {:authorize, :user_confirm}) do
      conn
      |> put_flash(:info, "Please click the link in the email we just sent you.")
      |> redirect(to: Routes.page_path(conn, :index, []))
    else
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset, action: Routes.user_path(conn, :create))

      _ ->
        conn
        |> put_flash(:error, "Unable to send confirmation email. Please contact support!")
        |> redirect(to: Routes.page_path(conn, :index, []))
    end
  end

  def update(conn, %{"user" => params}) do
    with %{"id" => id} <- Guardian.Plug.current_resource(conn),
         {:ok, user} <- Account.update(id, params) do
      conn
      |> put_flash(:info, "Profile updated")
      |> render("show.html", user: user)
    else
      {:error, changeset} ->
        render(conn, "update.html", changeset: changeset, action: Routes.user_path(conn, :update))

      _ ->
        conn
        |> redirect(to: Routes.session_path(conn, :index, []))
    end
  end

  # render update form
  def enchant(conn, _params) do
    with %{"id" => id} <- Guardian.Plug.current_resource(conn),
         %User{} = user <- Account.read(id) do
      changeset = User.changeset(user)
      render(conn, "update.html", changeset: changeset, action: Routes.user_path(conn, :update))
    else
      _ ->
        conn
        |> redirect(to: Routes.session_path(conn, :index, []))
    end
  end

  def new(conn, _params) do
    with false <- Guardian.Plug.authenticated?(conn, []) do
      changeset = User.changeset(%User{})
      render(conn, "new.html", changeset: changeset, action: Routes.user_path(conn, :create))
    else
      _ ->
        conn
        |> redirect(to: Routes.user_path(conn, :index, []))
    end
  end

  def show(conn, %{"username" => username}) do
    with true <- Regex.match?(~r/^[a-zA-Z_]+$/, username),
         %User{} = user <- Account.read(username) do
      conn
      |> render("show.html", user: user)
    else
      _ ->
        conn
        |> redirect(to: Routes.user_path(conn, :index, []))
    end
  end

  def authorize(conn, %{"token" => token}) do
    with {:ok, %{"sub" => %{"id" => id}}} <- BureauWeb.Guardian.decode_and_verify(token),
         {:ok, user} <- Account.update(id, %{verified: true}) do
      user
      |> BureauWeb.Authentication.authorize(conn)
      |> put_flash(:info, "Signed in as #{user.username}")
      |> redirect(to: Routes.user_path(conn, :enchant, []))
    else
      _ ->
        conn
        |> put_flash(:error, "Sorry this link is no longer valid")
        |> redirect(to: Routes.page_path(conn, :index, []))
    end
  end

  def authorize(conn, _) do
    conn
    |> put_status(:temporary_redirect)
    |> redirect(to: Routes.page_path(conn, :not_found, []))
  end

  def password(conn, %{"token" => token}) do
    with {:ok, %{"sub" => %{"id" => id}}} <- BureauWeb.Guardian.decode_and_verify(token),
         user = %Bureau.User{} <- Account.read(id) do
      changeset = User.changeset(user)

      render(conn, "password.html",
        changeset: changeset,
        action: Routes.user_path(conn, :update_password)
      )
    else
      _ ->
        conn
        |> put_flash(:error, "Sorry this link is no longer valid")
        |> redirect(to: Routes.page_path(conn, :index, []))
    end
  end

  def password(conn, _) do
    conn
    |> put_status(:temporary_redirect)
    |> redirect(to: Routes.page_path(conn, :not_found, []))
  end

  def update_password(conn, %{"update" => params}) do
    with {id, _} <- Integer.parse(params["id"]),
         {:ok, user} <- Account.update(id, params) do
      conn
      |> put_flash(:info, "Password updated")
      |> render("show.html", user: user)
    else
      {:error, changeset} ->
        render(conn, "password.html",
          changeset: changeset,
          action: Routes.user_path(conn, :update_password)
        )
    end
  end

  def delete(conn = %{private: %{:guardian_default_resource => %{"id" => id}}}, _) do
    Account.delete(id)

    conn
    |> put_flash(:info, "Account deleted")
    |> Guardian.Plug.sign_out(BureauWeb.Guardian, [])
    |> clear_session()
    |> redirect(to: Routes.session_path(conn, :index, []))
  end

  def logout(conn, _params) do
    conn
    |> Guardian.Plug.sign_out(BureauWeb.Guardian, [])
    |> clear_session()
    |> put_flash(:info, "Signed out successfully")
    |> redirect(to: Routes.session_path(conn, :index, []))
  end
end
