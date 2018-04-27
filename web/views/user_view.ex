defmodule Twitterproject.UserView do
  use Twitterproject.Web, :view

  def render("index.json", %{users: users}) do
    %{data: render_many(users, Twitterproject.UserView, "user.json")}
  end

  def render("show.json", %{user: user}) do
    %{data: render_one(user, Twitterproject.UserView, "user.json")}
  end

  def render("user.json", %{user: user}) do
    %{id: user.id,
      first_name: user.first_name}
  end
end
