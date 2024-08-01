defmodule Place.SocketHandler do
  @behaviour :cowboy_websocket

  def init(request, _state) do
    state = %{}
    {:cowboy_websocket, request, state}
  end

  def websocket_init(state) do
    Phoenix.PubSub.subscribe(Place.PubSub, "pixels")
    Phoenix.PubSub.subscribe(Place.PubSub, "users")
    :ets.update_counter(:users_count, :count, {2, 1}, {:count, 0})
    broadcast_users_count()
    {:ok, state}
  end

  def websocket_handle({:text, "ping"}, state) do
    {:reply, {:text, "pong"}, state}
  end

  def websocket_handle(_data, state) do
    {:ok, state}
  end

  def websocket_info({:pixel_update, pixel}, state) do
    {:reply, {:text, Jason.encode!(%{type: "pixel_update", payload: pixel})}, state}
  end

  def websocket_info({:users_count, count}, state) do
    {:reply, {:text, Jason.encode!(%{type: "users_count", count: count})}, state}
  end

  def websocket_info(_info, state) do
    {:ok, state}
  end

  def terminate(_reason, _req, _state) do
    :ets.update_counter(:users_count, :count, {2, -1}, {:count, 0})
    broadcast_users_count()
    :ok
  end

  defp broadcast_users_count do
    count = :ets.lookup_element(:users_count, :count, 2)
    Phoenix.PubSub.broadcast(Place.PubSub, "users", {:users_count, count})
  end
end
