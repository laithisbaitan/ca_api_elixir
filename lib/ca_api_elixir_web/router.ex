defmodule CaApiElixirWeb.Router do
  use CaApiElixirWeb, :router
  # alias CaApiElixirWeb.{PageController, SearchController, CreateController, UpdateController, CaController}

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {CaApiElixirWeb.Layouts, :root}
    # plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", CaApiElixirWeb do
    pipe_through :browser

    get "/", PageController, :home
    post "/submit", PageController, :submit
    get "/img", PageController, :img_page

  end

  scope "/api", CaApiElixirWeb do
    pipe_through :api

    scope "/search" do
      post "/query", SearchController, :query_search
      post "/item", SearchController, :item_search
    end

    scope "/create" do
      post "/item", CreateController, :create_item
    end

    scope "/update" do
      put "/item", UpdateController, :update_item
    end

    scope "/delete" do
      # delete "/item", DeleteController, :delete_item
    end

  end

  scope "/admin", CaApiElixirWeb do
    pipe_through :browser

    get "/clear_token", CaController, :clear_token
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:ca_api_elixir, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: CaApiElixirWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
