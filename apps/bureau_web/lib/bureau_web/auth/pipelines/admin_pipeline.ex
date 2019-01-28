defmodule BureauWeb.Admin.Pipeline do
  use Guardian.Plug.Pipeline,
    otp_app: :bureau_web,
    error_handler: BureauWeb.Guardian.ErrorHandler,
    module: BureauWeb.Guardian

  # If there is a session token, restrict it to an access token and validate it
  plug Guardian.Plug.VerifySession, claims: %{"typ" => "admin"}
  # If there is an authorization header, restrict it to an access token and validate it
  plug Guardian.Plug.VerifyHeader, claims: %{"typ" => "admin"}
  # Load the user if either of the verifications worked
  plug Guardian.Plug.VerifyCookie, claims: %{"typ" => "admin"}
  plug Guardian.Plug.EnsureAuthenticated
  plug Guardian.Plug.LoadResource, ensure: true
end
