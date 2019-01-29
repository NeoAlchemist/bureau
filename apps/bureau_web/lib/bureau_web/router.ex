defmodule BureauWeb.Router do
  use BureauWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug BureauWeb.Plug.Session
  end

  pipeline :user do
    plug BureauWeb.User.Pipeline
  end

  pipeline :employer do
    plug BureauWeb.Employer.Pipeline
  end

  pipeline :admin do
    plug BureauWeb.Admin.Pipeline
    plug :put_layout, {BureauWeb.LayoutAdminView, :admin}
    # Apply admin layout at the router level
    # https://cultivatehq.com/posts/how-to-set-different-layouts-in-phoenix/
  end

  scope "/", BureauWeb do
    pipe_through [:browser]

    get "/", PageController, :index

    # password reset
    get "/incanto/password", SessionController, :password
    post "/incanto/password", SessionController, :reset_pswrd

    # login
    resources "/incanto", SessionController, only: [:index, :create]
  
    # users
    get "/alchemists/authorize", UserController, :authorize
    get "/alchemists/join", UserController, :new

    get "/alchemists/password", UserController, :password
    post "/alchemists/password", UserController, :update_password

    resources "/alchemists", UserController, only: [:index, :create]

    scope "/alchemists" do
      pipe_through [:user]
  
      get "/enchant", UserController, :enchant
      put "/enchant", UserController, :update
      delete "/retirement", UserController, :delete
  
      # logout
      delete "/logout", UserController, :logout
    end

    get "/alchemists/:username", UserController, :show

    # job offers
    get "/jobs/authorize", JobController, :authorize
    resources "/jobs", JobController, only: [:index, :show, :new, :create]

    # job owners area
    scope "/jobs" do
      pipe_through [:employer]
  
      delete "/close", JobController, :close
    end
  
    # admin area
    resources "/admin/login", AdminSessionController, only: [:index, :create]
    
    scope "/admin" do
      pipe_through [:admin]
  
      get "/dashboard", DashboardController, :index
      resources "/users", AdminUserController, only: [:index, :show, :update, :delete]
      resources "/jobs", AdminJobController, only: [:index, :show, :update, :delete]
  
      delete "/logout", AdminSessionController, :delete
    end

    get "/*path", PageController, :not_found
  end
end
