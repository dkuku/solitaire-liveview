defmodule SolitaireWeb.SolitaireLive do
  use Phoenix.LiveView
  require Logger

  def mount(_session, socket) do
    socket = assign(socket, :counter, 1)
    {:ok, socket}
  end

  def render(assigns) do
    ~L"""
    <label>counter: <%= @counter %></label>
    <button phx-click="increment">+ </button>
    """
  end

  def handle_event("increment", _, socket) do
    #socket = assign(socket, :counter, socket.assigns.counter + 1)
    socket = update(socket, :counter, &(&1 + 1))

    {:noreply, socket}
  end
end
