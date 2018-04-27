defmodule Twitterproject.User do
  use Twitterproject.Web, :model

  alias Comeonin.pbkdf2

  schema "users" do
    field :user_name, :string
    field :hashed_password, :string
    field :password, :string, virtual: true

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def registration_changeset(user, params \\ :empty) do
    user
    |> cast(params, [:user_name, :password])
    |> validate_required([:user_name, :password])
    |> validate_confirmation(:password)
    |> validate_length(:password, min: 6)
    |> validate_format(:user_name, ~r/^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$/)
    |> unique_constraint(:user_name)
    |> put_password_hash
  end

  defp put_password_hash(changeset) do
    case changeset do
      %Ecto.Changeset{ valid?: true, changes: %{ password: pass } } ->
        put_change(changeset, :hashed_password, Comeonin.pbkdf2.hashpwsalt(pass))
      _ ->
        changeset
    end
  end
end
