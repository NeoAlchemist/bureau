defmodule BureauWeb.DashboardController do
  use BureauWeb, :controller

  def index(conn, _params) do
    with {:ok, user_stats} <- Bureau.Admin.statistics(Bureau.User),
         {:ok, job_stats} <- Bureau.Admin.statistics(Bureau.JobOffer) do
      render(conn, "index.html", users: user_stats, jobs: job_stats)
    else
      _ ->
        render(conn, "500.html")
    end
  end
end
