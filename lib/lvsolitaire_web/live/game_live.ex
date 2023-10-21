defmodule LVSolitaireWeb.GameLive do
  @moduledoc """
  Frontend logic

  game data structure
  {
   { deck, waste} = reserve,
   [ {invisible, visible}, ] = tableau,
   [[], [], [], []] = foundation
  }
  """
  use Phoenix.LiveView
  alias Solitaire

  import LVSolitaireWeb.CardComponent

  def mount(params, session, socket) do
    IO.inspect(params, label: :params)
    IO.inspect(session, label: :session)
    IO.inspect(socket, label: :socket)
    {:ok, pid} = Solitaire.start_link([])

    socket =
      socket
      |> assign(:clicked, nil)
      |> assign(:pid, pid)
      |> assign(:state, :initial)
      |> assign_game()

    {:ok, socket}
  end

  @spec render(LiveView.Socket.assigns()) :: LiveView.Rendered.t()
  def render(assigns) do
    :telemetry.execute(
      [:web, :render],
      %{ts: :os.system_time(:millisecond)}
    )

    ~H"""
    <center>
      <div class="playingCards inline">
        <ul class="deck inline">
          <%= if @deck == [] do %>
            <.card pile={:deck} card={nil} />
          <% else %>
            <.card pile={:deck} card={:back} />
          <% end %>
        </ul>
      </div>

      <div class="playingCards inline">
        <ul class="deck inline">
          <.card pile={:waste} card={@waste} />
        </ul>
      </div>

      <%= for {foundation, idx}  <- @foundation do %>
        <div class="playingCards inline">
          <ul class="deck inline">
            <.card pile={:foundation} card={foundation} />
          </ul>
        </div>
      <% end %>
    </center>

    <center phx-click="unselect">
      <%= for {{invisible, visible}, idx}  <- @tableau do %>
        <div class="playingCards inline">
          <ul class="tableau">
            <%= if invisible == [] and visible == [] do %>
              <.card pile={:tableau} card={nil} index={idx} />
            <% else %>
              <%= for _card  <- invisible do %>
                <.card pile={:tableau} card={:back} index={idx} />
              <% end %>
              <%= for card  <- Enum.reverse(visible) do %>
                <.card pile={:tableau} card={card} index={idx} />
              <% end %>
            <% end %>
          </ul>
        </div>
      <% end %>
    </center>
    """
  end

  def possible_moves(socket), do: Solitaire.possible_moves(socket.assigns.pid) |> IO.inspect()
  # TODO fix when moving valid card to different pile
  def handle_event("click-empty", params, socket) do
    socket
    |> possible_moves()
    |> filter_by_clicked(params, socket.assigns.clicked)
    |> handle_clicked_empty(params, socket)
  end

  def handle_event("click", params, socket) do
    handle_clicked(params, socket, socket.assigns.clicked)
  end

  def handle_event("moves", params, %{assigns: %{clicked: {_rank, suit}}} = socket)
      when suit in [1, 13] do
    socket
    |> possible_moves()
    |> filter_by_clicked(params, socket.assigns.clicked)
    |> handle_clicked_empty(params, socket)
  end

  def handle_event("moves", _params, %{assigns: %{game: {{[], _}, _, _}}} = socket) do
    Solitaire.reshuffle(socket.assigns.pid)

    socket
    |> assign_game()
    |> return_socket()
  end

  def handle_event("moves", _params, socket) do
    {:noreply, socket}
  end

  def handle_event("click-deck", _, socket) do
    handle_deck_click(socket, socket.assigns.deck)
  end

  def handle_event("unselect", _, socket) do
    socket
    |> assign(:clicked, nil)
    |> return_socket()
  end

  def handle_clicked_empty(moves, params, socket) when moves == [] do
    socket
    |> assign(:clicked, format_card(params))
    |> return_socket()
  end

  def handle_clicked_empty(moves, _params, socket) do
    Solitaire.perform(socket.assigns.pid, Enum.fetch!(moves, 0))

    socket
    |> assign_game()
    |> assign(:clicked, nil)
    |> return_socket()
  end

  def handle_clicked(params, socket, nil) do
    socket
    |> possible_moves()
    |> check_possible_moves(params)
    |> perform_move_with_unselected_card(socket, params)
    |> return_socket()
  end

  def handle_clicked(params, socket, clicked) do
    socket
    |> possible_moves()
    |> filter_by_clicked(params, clicked)
    |> perform_move_with_selected_card(socket, params)
    |> return_socket()
  end

  def perform_move_with_unselected_card(moves, socket, params) when moves == [] do
    assign(socket, :clicked, format_card(params))
  end

  def perform_move_with_unselected_card(moves, socket, _params) do
    Solitaire.perform(socket.assigns.pid, Enum.fetch!(moves, 0))

    socket
    |> assign_game()
    |> assign(:clicked, nil)
  end

  def perform_move_with_selected_card(moves, socket, params) when moves == [] do
    assign(socket, :clicked, format_card(params))
  end

  def perform_move_with_selected_card(moves, socket, _params) do
    Solitaire.perform(socket.assigns.pid, Enum.fetch!(moves, 0))

    socket
    |> assign_game()
    |> assign(:clicked, nil)
  end

  def return_socket(socket) do
    {:noreply, socket}
  end

  def handle_deck_click(socket, deck) when deck == [] do
    socket
    |> return_socket()
  end

  def handle_deck_click(socket, _deck) do
    Solitaire.turn(socket.assigns.pid)

    socket
    |> assign_game()
    |> return_socket()
  end

  def check_possible_moves(moves, %{"index" => index, "pile" => pile_type} = _params) do
    moves
    |> Enum.filter(fn {pile_from, from_idx, _pile_to, _to_idx, _card} ->
      from_idx == String.to_integer(index) and Atom.to_string(pile_from) == pile_type
    end)
  end

  def filter_by_clicked(moves, _params, nil), do: moves

  def filter_by_clicked(moves, %{} = _params, clicked) do
    moves
    |> Enum.filter(fn {_pile_from, _from_idx, _pile_to, _to_idx, card} ->
      card == clicked
    end)
  end

  def filter_by_clicked(moves, %{"index" => index, "pile" => pile_type} = _params, clicked) do
    moves
    |> Enum.filter(fn {_pile_from, _from_idx, pile_to, to_idx, card} ->
      to_idx == String.to_integer(index) and Atom.to_string(pile_to) == pile_type and
        card == clicked
    end)
  end

  def format_card(%{"rank" => rank, "suit" => suit}) do
    {String.to_existing_atom(suit), String.to_integer(rank)}
  end

  def format_card(_), do: nil

  defp assign_game(socket) do
    {
      {deck, waste} = _reserve,
      tableau,
      foundation
    } = Solitaire.get_state(socket.assigns.pid)

    socket
    |> assign(:deck, deck)
    |> assign(:waste, Enum.at(waste, 0))
    |> assign(:foundation, foundation |> Enum.map(&first(&1)) |> Enum.with_index())
    |> assign(:tableau, Enum.with_index(tableau))
  end

  def first([]), do: nil
  def first([hd | _]), do: hd
  def len(nil), do: 0
  def len(list) when is_tuple(list), do: 1
  def len(list) when is_list(list), do: length(list)
end
