defmodule BureauWeb.Plug.Session do
  @behaviour Plug
  import Plug.Conn

  @moduledoc """
  This plugin need to load data from guardian token.
  Having different token types, if you don't specify to guardian plugin wich claims typ to load
  it will load defualt typ => access, but as I need to load 2 different type this plugin load 
  what ever typ there is inside token.
  """

  def init(opts), do: opts

  def call(conn = %{private: %{:guardian_default_resource => _}}, _opts), do: conn

  def call(conn = %{private: %{:plug_session => %{"guardian_default_token" => token}}}, _opts)
      when not is_nil(token) do
    with {:ok, claims} <- BureauWeb.Guardian.decode_and_verify(token) do
      conn
      |> put_private(:guardian_default_claims, claims)
      |> put_private(:guardian_default_resource, claims["sub"])
      |> put_private(:guardian_default_token, token)
    else
      _ -> conn
    end
  end

  def call(conn, _), do: conn
end
