defmodule TwitterprojectWeb.PageController do
  use TwitterprojectWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
