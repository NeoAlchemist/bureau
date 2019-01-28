defmodule BureauWeb.LayoutAdminView do
  use BureauWeb, :view

  def active_class?("/admin/" <> path, attr) when path == attr, do: "active"
  def active_class?(_, _), do: ""

  def title("/admin/" <> <<h::utf8, tail::binary>>), do: String.upcase(<<h::utf8>>) <> tail
  def title(_), do: ""
end
