defmodule Testpk.Repo do
  use Ecto.Repo,
    otp_app: :testpk,
    adapter: Ecto.Adapters.Postgres
end
