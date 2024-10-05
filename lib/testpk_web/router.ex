defmodule TestpkWeb.Router do
  use TestpkWeb, :router

  (
    alias TestpkWeb.SessionHooks.AssignUser
    alias TestpkWeb.SessionHooks.RequireUser
    import TestpkWeb.Session, only: [fetch_current_user: 2]
  )

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {TestpkWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", TestpkWeb do
    pipe_through :browser

    get "/", PageController, :home
  end

  # HTTP controller routes
  scope "/", TestpkWeb do
    pipe_through :browser

    post "/session", Session, :create
    delete "/session", Session, :delete
  end

  # Unprotected LiveViews
  live_session :guest, on_mount: [AssignUser] do
    scope "/", TestpkWeb do
      pipe_through :browser

      live "/sign-up", RegistrationLive
      live "/sign-in", AuthenticationLive
    end
  end

  # Protected LiveViews
  live_session :authenticated, on_mount: [AssignUser, RequireUser] do
    scope "/", TestpkWeb do
      pipe_through :browser

      # Example
      # live "/room/:room_id", RoomLive
    end
  end

  # Other scopes may use custom stacks.
  # scope "/api", TestpkWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:testpk, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: TestpkWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end