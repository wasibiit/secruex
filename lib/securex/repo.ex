defmodule SecureX.Repo do
  use Ecto.Repo,
    otp_app: :securex,
    adapter: Ecto.Adapters.Postgres
end
