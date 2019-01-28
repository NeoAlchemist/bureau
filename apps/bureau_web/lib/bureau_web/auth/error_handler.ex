defmodule BureauWeb.Guardian.ErrorHandler do
  import Plug.Conn
  use BureauWeb, :controller

  def auth_error(conn, {type, _reason}, _opts) do
    msg = to_string(type)

    conn
    |> put_flash(:info, "#{msg}")
    |> put_status(:temporary_redirect)
    |> redirect(to: Routes.session_path(conn, :index, []))
  end
end
