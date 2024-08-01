defmodule Place.Router do
  use Plug.Router

  plug(Plug.Static,
    at: "/",
    from: :place
  )

  plug(:match)
  plug(:dispatch)

  get "/" do
    send_file(conn, 200, "priv/static/index.html")
  end

  post "/pixel" do
    {:ok, body, conn} = read_body(conn)
    pixel = Jason.decode!(body)
    Place.PixelStore.set_pixel(pixel["x"], pixel["y"], pixel["color"])
    send_resp(conn, 200, "OK")
  end

  get "/pixels" do
    pixels = Place.PixelStore.get_all_pixels()

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Jason.encode!(pixels))
  end

  match _ do
    send_resp(conn, 404, "Not found")
  end
end
