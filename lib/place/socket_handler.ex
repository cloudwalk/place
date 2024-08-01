defmodule Place.SocketHandler do
  @behaviour :cowboy_websocket

  def init(request, _state) do
    state = %{}
    {:cowboy_websocket, request, state}
  end

  def websocket_init(state) do
    Phoenix.PubSub.subscribe(Place.PubSub, "pixels")
    {:ok, state}
  end

  def websocket_handle({:text, "ping"}, state) do
    {:reply, {:text, "pong"}, state}
  end

  def websocket_handle(_data, state) do
    {:ok, state}
  end

  def websocket_info({:pixel_update, pixel}, state) do
    {:reply, {:text, Jason.encode!(pixel)}, state}
  end

  def websocket_info(_info, state) do
    {:ok, state}
  end
end
