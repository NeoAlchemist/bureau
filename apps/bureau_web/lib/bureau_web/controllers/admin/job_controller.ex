defmodule BureauWeb.AdminJobController do
  use BureauWeb, :controller
  alias Bureau.{Offer, JobOffer}

  def index(conn, %{"search" => %{"company_name" => name}}) do
    list = Offer.list(like: {:company_name, name}, limit: 20)
    render(conn, "index.html", jobs: list)
  end

  def index(conn, _) do
    render(conn, "index.html", jobs: Offer.list(order: :desc, limit: 20))
  end

  def update(conn, %{"id" => id, "job" => params}) do
    with {int, _} <- Integer.parse(id),
         {:ok, job} <- Offer.update(int, params) do
      conn
      |> put_flash(:info, "Job offer updated")
      |> render("show.html", job: job)
    else
      _ ->
        render(conn, "500.html")
    end
  end

  def show(conn, %{"id" => id}) do
    with {int, _} <- Integer.parse(id),
         %JobOffer{} = job <- Offer.read(int) do
      conn
      |> render("show.html", job: job)
    else
      _ ->
        conn
        |> redirect(to: Routes.admin_job_path(conn, :index, []))
    end
  end

  def delete(conn, %{"id" => id}) do
    with {int, _} <- Integer.parse(id) do
      Offer.delete(int)

      conn
      |> put_flash(:info, "Job offer deleted")
      |> redirect(to: Routes.admin_job_path(conn, :index, []))
    else
      _ ->
        conn
        |> redirect(to: Routes.admin_job_path(conn, :index, []))
    end
  end
end
