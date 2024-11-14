defmodule PhxCalculatorWeb.Router do
git   use PhxCalculatorWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {PhxCalculatorWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", PhxCalculatorWeb do
    pipe_through :browser

    live "/", CalculatorLive, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", PhxCalculatorWeb do
  #   pipe_through :api
  # end
end
