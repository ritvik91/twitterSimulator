defmodule Twitterproject.UserTest do
  use Twitterproject.ModelCase

  alias Twitterproject.User

  @valid_attrs %{first_name: "some first_name"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = User.changeset(%User{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = User.changeset(%User{}, @invalid_attrs)
    refute changeset.valid?
  end
end
