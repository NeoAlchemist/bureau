defmodule BureauWeb.User.Pipeline do
  use Guardian.Plug.Pipeline,
    otp_app: :bureau_web,
    error_handler: BureauWeb.Guardian.ErrorHandler,
    module: BureauWeb.Guardian

  # If there is a session token, restrict it to an access token and validate it
  plug Guardian.Plug.VerifySession, claims: %{"typ" => "user"}
  # If there is an authorization header, restrict it to an access token and validate it
  plug Guardian.Plug.VerifyHeader, claims: %{"typ" => "user"}
  # Load the user if either of the verifications worked
  plug Guardian.Plug.VerifyCookie, claims: %{"typ" => "user"}
  plug Guardian.Plug.EnsureAuthenticated
  plug Guardian.Plug.LoadResource, ensure: true
end
