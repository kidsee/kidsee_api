defmodule KidseeApiWeb.UserView do
  use KidseeApiWeb, :view

  attributes [
    :username,
    :email,
    :birthdate,
    :school,
    :city,
    :avatar
  ]

  def render("token.json-api", %{token: token}) do
    %{token: token}
  end
end