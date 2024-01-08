defmodule TickexWeb.Router do
  use TickexWeb, :router

  import TickexWeb.UserAuth

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_live_flash)
    plug(:put_root_layout, html: {TickexWeb.Layouts, :root})
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
    plug(:fetch_current_user)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  # Other scopes may use custom stacks.
  # scope "/api", TickexWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard in development
  if Application.compile_env(:tickex, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through(:browser)

      live_dashboard("/dashboard", metrics: TickexWeb.Telemetry)
    end
  end

  ## Authentication routes

  scope "/", TickexWeb do
    pipe_through([:browser, :redirect_if_user_is_authenticated])

    post("/auth", UserSessionController, :create)
  end

  scope "/", TickexWeb do
    pipe_through([:browser, :require_authenticated_user])

    live_session :require_authenticated_user,
      on_mount: [{TickexWeb.UserAuth, :ensure_authenticated}] do
      live("/user/settings", UserSettingsLive, :edit)
      # live("/user/settings/confirm_email/:token", UserSettingsLive, :confirm_email)
      live("/events/new", EventLive.Index, :new)
      live("/events/:id/edit", EventLive.Index, :edit)
      live("/events/:id/show/edit", EventLive.Show, :edit)
      live("/events/:id/redeem", RedeemLive.Index, :index)

      live("/user/tickets", TicketLive.Index, :user_index)
      live("/tickets/:id", TicketLive.Show, :user_show)
    end
  end

  scope "/", TickexWeb do
    pipe_through([:browser])
    delete("/logout", UserSessionController, :delete)

    live_session :current_user,
      on_mount: [{TickexWeb.UserAuth, :mount_current_user}] do
      live("/users/confirm/:token", UserConfirmationLive, :edit)
      live("/users/confirm", UserConfirmationInstructionsLive, :new)
    end
  end

  scope "/", TickexWeb do
    pipe_through(:browser)

    get("/", PageController, :home)

    live_session :default,
      on_mount: [{TickexWeb.UserAuth, :mount_current_user}] do
      live("/events", EventLive.Index, :index)
      live("/events/:id", EventLive.Show, :show)
    end
  end
end
