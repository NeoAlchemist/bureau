defmodule BureauWeb.EmailView do
  use BureauWeb, :view

  def site_url, do: Application.get_env(:bureau_web, BureauWeb.Endpoint)[:url][:host]
end
