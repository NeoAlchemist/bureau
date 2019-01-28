defmodule BureauWeb.LayoutView do
  use BureauWeb, :view

  # All functions defined here are available insiede template, specialy usefull for pattern matching!

  def logged?(%{private: %{:guardian_default_claims => %{"typ" => typ}}}) when not is_nil(typ),
    do: typ

  def logged?(_), do: false

  def get_name(%{private: %{:guardian_default_resource => %{"name" => name}}}), do: name
  def get_name(_), do: ""

  def img_link(conn) do
    Mix.env()
    |> case do
      :prod -> "#{conn.scheme}://#{conn.host}"
      _ -> "#{conn.scheme}://#{conn.host}:#{conn.port}"
    end
  end

  def email_domain, do: Application.get_env(:bureau_web, BureauWeb.Mailer)[:domain]
end
