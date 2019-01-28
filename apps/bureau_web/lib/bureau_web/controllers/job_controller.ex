defmodule BureauWeb.JobController do
  use BureauWeb, :controller
  alias Bureau.{Offer, JobOffer}
  alias BureauWeb.SearchJob

  plug :scrub_params, "job_offer" when action in [:create]

  # pattern matching if there are some search params for next/previous page
  def index(conn, %{"page" => page, "search_job" => params}) do
    params
    |> Map.merge(%{"page" => page})
    |> SearchJob.changeset()
    |> render_list(conn)
  end

  def index(conn, %{"search_job" => params}) do
    params
    |> SearchJob.changeset()
    |> render_list(conn)
  end

  def index(conn, _), do: render_list(SearchJob.changeset(), conn)

  defp render_list(changeset, conn) do
    render(conn, "index.html",
      changeset: %{changeset | action: :insert},
      action: Routes.job_path(conn, :index),
      jobs: changeset.changes.result.entries,
      page_number: changeset.changes.result.page_number,
      total_pages: changeset.changes.result.total_pages
    )
  end

  def create(conn, %{"job_offer" => params}) do
    with {:ok, offer} <- Offer.create(params),
         %Bamboo.Email{} <- BureauWeb.Email.send(conn, offer, {:authorize, :job_confirm}) do
      conn
      |> put_flash(:info, "Please click the link in the email we just sent you.")
      |> redirect(to: Routes.page_path(conn, :index, []))
    else
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset, action: Routes.job_path(conn, :create))

      _ ->
        conn
        |> put_flash(:error, "Unable to send confirmation email. Please contact support!")
        |> redirect(to: Routes.page_path(conn, :index, []))
    end
  end

  def new(conn, _params) do
    with false <- Guardian.Plug.authenticated?(conn, []) do
      changeset = JobOffer.changeset(%JobOffer{})
      render(conn, "new.html", changeset: changeset, action: Routes.job_path(conn, :create))
    else
      _ ->
        conn
        |> put_flash(:error, "Please sign out before creating job offer.")
        |> redirect(to: Routes.page_path(conn, :index, []))
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
        |> redirect(to: Routes.job_path(conn, :index, []))
    end
  end

  def authorize(conn, %{"token" => token}) do
    with {:ok, %{"sub" => %{"id" => id}}} <- BureauWeb.Guardian.decode_and_verify(token),
         %JobOffer{close: false} = job <- Offer.read(id),
         {:ok, new_job} <- Offer.update(job, %{verified: true}) do
      new_job
      |> IO.inspect()
      |> BureauWeb.Authentication.authorize(conn)
      |> put_flash(:info, "Welcome #{job.company_name}")
      |> redirect(to: Routes.page_path(conn, :index, []))
    else
      _ ->
        conn
        |> put_flash(:error, "Sorry this link is no longer valid")
        |> redirect(to: Routes.page_path(conn, :index, []))
    end
  end

  def close(conn = %{private: %{:guardian_default_resource => %{"id" => id}}}, _params) do
    Offer.update(id, %{close: true})

    conn
    |> put_flash(:info, "Thank you, job offer closed!")
    |> Guardian.Plug.sign_out(BureauWeb.Guardian, [])
    |> redirect(to: Routes.page_path(conn, :index, []))
  end
end
