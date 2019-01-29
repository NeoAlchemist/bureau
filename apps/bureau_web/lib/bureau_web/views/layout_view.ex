defmodule BureauWeb.LayoutView do
  use BureauWeb, :view

  # All functions defined here are available insiede template, specialy usefull for pattern matching!

  def logged?(conn), do: Plug.Conn.get_session(conn, :typ)
  
  def get_name(conn) do 
    conn
    |> Plug.Conn.get_session(:account)
    |> case do
      map when is_map(map) -> Map.get(map, "name")
      _ -> ""
    end
  end

  def img_link(conn) do
    Mix.env()
    |> case do
      :prod -> "#{conn.scheme}://#{conn.host}"
      _ -> "#{conn.scheme}://#{conn.host}:#{conn.port}"
    end
  end

  def email_domain, do: Application.get_env(:bureau_web, BureauWeb.Mailer)[:domain]
end
