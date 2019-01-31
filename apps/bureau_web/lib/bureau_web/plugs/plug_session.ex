defmodule BureauWeb.Plug.Session do
  @behaviour Plug
  import Plug.Conn

  @moduledoc """
  This plugin need to load data from guardian token if there isn't already loaded into session.
  """

  def init(opts), do: opts

  #if there is already account data inside session then skip
  def call(conn = %{private: %{plug_session: %{"account" => _acc}}}, _opts), do: conn

  #put inside session guardian_resources from session token
  def call(conn = %{private: %{:plug_session => %{"guardian_default_token" => token}}}, _opts)
      when not is_nil(token) do
    with {:ok, claims} <- BureauWeb.Guardian.decode_and_verify(token) do
      conn
      |> put_session(:account, claims["sub"])
      |> put_session(:typ, claims["typ"])
    else
      _ -> conn
    end
  end

  def call(conn, _), do: conn
end
