# This is just an example how it could be implemented.
# The Authentication could also been implemente not using protocols.
# Having protocol for each type would fit in our case.

# But I see also protocols like blade with two edges! 
# It provide a great way to add extension points to your code 
# but because a protocol can dispatch to any data type, 
# the protocol must check on every call if an implementation 
# for the given type exists. This may be expensive.

# Docs: https://hexdocs.pm/mix/Mix.Tasks.Compile.Protocols.html#content

# Also you can read more about it in this article: 
# https://medium.com/everydayhero-engineering/extensibility-in-elixir-using-protocols-2e8fb0a35c48

# If we want to implemente module whitout protocol in this case, we could write something like this:

# 	defmodule BureauWeb.Authentication do
# 		def authorize(conn, %{id: id, verified: true, __struct__: typ}) do
# 			BureauWeb.Guardian.Plug.sign_in(conn, %{id: id}, %{"typ" => "#{typ}"})
# 		end
# 		def authorize(conn, _), do: conn
# 	end

# When implementing protols first parameter should be the type.
# Also defimpl can be split in different files, I just keep all of them here for convenience

defprotocol BureauWeb.Authentication do
  @fallback_to_any true

  @spec authorize(Ecto.Schema.t(), Plug.Conn.t()) :: Plug.Conn.t()
  def authorize(schema, conn)
end

defimpl BureauWeb.Authentication, for: Bureau.User do
  def authorize(%Bureau.User{username: username, id: id, verified: true}, conn) do
    BureauWeb.Guardian.Plug.sign_in(conn, %{id: id, name: username}, %{"typ" => "user"})
  end
end

defimpl BureauWeb.Authentication, for: Bureau.JobOffer do
  def authorize(%Bureau.JobOffer{company_name: name, id: id, verified: true}, conn) do
    BureauWeb.Guardian.Plug.sign_in(conn, %{id: id, name: name}, %{"typ" => "employer"})
  end
end

defimpl BureauWeb.Authentication, for: Bureau.Admin.Account do
  def authorize(%Bureau.Admin.Account{username: name}, conn) do
    BureauWeb.Guardian.Plug.sign_in(conn, %{name: name}, %{"typ" => "admin"})
  end
end

defimpl BureauWeb.Authentication, for: Any do
  def authorize(_, conn), do: conn
end
