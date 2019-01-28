defmodule BureauWeb.Email do
  use Bamboo.Phoenix, view: BureauWeb.EmailView

  @domain Application.get_env(:bureau_web, BureauWeb.Mailer)[:domain]

  @spec compose(%Email{}) :: %Bamboo.Email{} | :error
  def compose(email = %Email{}) when is_map(email) do
    Mix.env()
    |> case do
      :prod ->
        new_email()
        |> to(email.to)
        |> from("Bureau <#{email.from}@#{@domain}>")
        |> subject(email.subject)
        |> put_header("Reply-To", "support@#{@domain}")
        |> put_layout({BureauWeb.LayoutView, :email})
        |> assign(:email, email.data)
        |> render(email.template)

      _ ->
        new_email()
        |> to(email.to)
        |> from("<#{System.get_env("MY_EMAIL")}>")
        |> subject(email.subject)
        |> put_header("Reply-To", "#{System.get_env("MY_EMAIL")}")
        |> put_layout({BureauWeb.LayoutView, :email})
        |> assign(:email, email.data)
        |> render(email.template)
    end
  end

  def compose(_), do: :error

  @spec send(%Plug.Conn{}, %Bureau.User{} | %Bureau.JobOffer{}, {atom, atom}) ::
          {:error, any} | %Bamboo.Email{}
  def send(conn, %{id: id, email: email, __struct__: type}, {route, template}) do
    with {:ok, token, _} <-
           BureauWeb.Guardian.encode_and_sign(%{"id" => id}, %{}, ttl: {7, :days}) do
      compose(%Email{
        to: email,
        template: template,
        data: %{
          link: build_link(conn, {token, route, type})
        }
      })
      |> BureauWeb.Mailer.deliver_later()
    end
  end

  def send(_, _, _), do: {:error, :params}

  defp build_link(conn, {token, route, Bureau.User}) do
    host = if Mix.env() == :prod, do: "#{conn.host}", else: "#{conn.host}:#{conn.port}"

    "#{conn.scheme}://#{host}#{BureauWeb.Router.Helpers.user_path(conn, route, token: token)}"
    |> URI.encode()
  end

  defp build_link(conn, {token, route, Bureau.JobOffer}) do
    host = if Mix.env() == :prod, do: "#{conn.host}", else: "#{conn.host}:#{conn.port}"

    "#{conn.scheme}://#{host}#{BureauWeb.Router.Helpers.job_path(conn, route, token: token)}"
    |> URI.encode()
  end
end
