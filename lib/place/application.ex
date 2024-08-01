defmodule Place.Application do
  use Application

  def start(_type, _args) do
    children = [
      {Plug.Cowboy, scheme: :http, plug: Place.Router, options: [port: 4000]},
      {Place.PixelStore, []}
    ]

    opts = [strategy: :one_for_one, name: Place.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
