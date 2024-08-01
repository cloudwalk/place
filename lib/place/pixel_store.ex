defmodule Place.PixelStore do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def init(state) do
    {:ok, state}
  end

  def set_pixel(x, y, color) do
    GenServer.cast(__MODULE__, {:set_pixel, x, y, color})
  end

  def get_all_pixels do
    GenServer.call(__MODULE__, :get_all_pixels)
  end

  def handle_cast({:set_pixel, x, y, color}, state) do
    key = "#{x},#{y}"
    new_state = Map.put(state, key, color)
    pixel = %{x: x, y: y, color: color}
    Phoenix.PubSub.broadcast(Place.PubSub, "pixels", {:pixel_update, pixel})
    {:noreply, new_state}
  end

  def handle_call(:get_all_pixels, _from, state) do
    {:reply, state, state}
  end
end
