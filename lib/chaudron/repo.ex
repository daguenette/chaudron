defmodule Chaudron.Repo do
  use Ecto.Repo,
    otp_app: :chaudron,
    adapter: Ecto.Adapters.Postgres
end
