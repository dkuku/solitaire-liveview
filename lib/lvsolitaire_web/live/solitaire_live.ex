defmodule LVSolitaireWeb.LVSolitaireLive do
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

    <div class="playingCards">
      <ul class="table">
        <li>
          <div class="card big joker"><span class="rank">+</span><span class="suit">Joker</span></div>
        </li>
        <li>
          <div class="card little joker"><span class="rank">-</span><span class="suit">Joker</span></div>
        </li>
        <li>
          <div class="card back">*</div>
        </li>
      </ul>
    </div>
    """
  end

  def handle_event("increment", _, socket) do
    #socket = assign(socket, :counter, socket.assigns.counter + 1)
    socket = update(socket, :counter, &(&1 + 1))

    {:noreply, socket}
  end
end
