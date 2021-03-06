defmodule KidseeApiWeb.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  import other functionality to make it easier
  to build common datastructures and query the data layer.

  Finally, if the test case interacts with the database,
  it cannot be async. For this reason, every test runs
  inside a transaction which is reset at the beginning
  of the test unless the test case is marked as async.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      # Import conveniences for testing with connections
      use Phoenix.ConnTest
      import KidseeApiWeb.Router.Helpers

      # The default endpoint for testing
      @endpoint KidseeApiWeb.Endpoint
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(KidseeApi.Repo)
    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(KidseeApi.Repo, {:shared, self()})
    end
    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end

  setup %{conn: conn} do
    # prepare authentication and content-type
    user = KidseeApi.UserFactory.insert(:user)
    {:ok, token, _claims} = KidseeApiWeb.Guardian.encode_and_sign(user)

    conn = conn
           |> Plug.Conn.put_req_header("content-type", "application/vnd.api+json")
           |> Plug.Conn.put_req_header("authorization", "Bearer #{token}")
    {:ok, conn: conn }
  end
end
