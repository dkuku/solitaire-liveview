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
  alias Solitaire.Game, as: Game
  alias Solitaire.Deck, as: Deck

  import LVSolitaireWeb.CardComponent
  @random_max 1_000_000

  def mount(_params, _session, socket) do
    game =
      Deck.new()
      |> Deck.shuffle(:rand.uniform(@random_max))
      |> Game.new()

    socket = assign(socket, :game, game)
    socket = assign(socket, :clicked, nil)
    socket = assign(socket, :state, :initial)
    {:ok, socket}
  end

  @spec render(LiveView.Socket.assigns()) :: LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <center>
      <% {reserve, tableau, foundation} = assigns.game %>
      <% {deck, waste} = reserve %>
      <div class="playingCards inline">
        <ul class="deck inline">
          <%= if len(deck)>0 do %>
            <.card pile={:deck} card={:back} />
          <% else %>
            <.card pile={:deck} card={nil} />
          <% end %>
        </ul>
      </div>

      <div class="playingCards inline">
        <ul class="deck inline">
          <.card pile={:waste} card={Enum.at(waste, 0)} index={0} />
        </ul>
      </div>

      <%= for {foundation, idx}  <- Enum.with_index(foundation) do %>
        <div class="playingCards inline">
          <ul class="deck inline">
            <.card pile={:foundation} card={Enum.at(foundation, 0)} index={idx} />
          </ul>
        </div>
      <% end %>
    </center>

    <center phx-click="unselect">
      <%= for {{invisible, visible}, idx}  <- Enum.with_index(tableau) do %>
        <div class="playingCards inline">
          <ul class="tableau">
            <%= if len(invisible)==0 and len(visible)==0 do %>
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

  def possible_moves(socket), do: Game.possible_moves(socket.assigns.game) |> IO.inspect()
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
    socket
    |> assign(:game, Game.reshuffle(socket.assigns.game))
    |> return_socket()
  end

  def handle_event("moves", _params, socket) do
    {:noreply, socket}
  end

  def handle_event("click-deck", _, socket) do
    {{deck, _}, _, _} = socket.assigns.game
    handle_deck_click(socket, deck)
  end

  def handle_event("unselect", _, socket) do
    socket
    |> assign(:clicked, nil)
    |> return_socket()
  end

  def handle_clicked_empty(moves, params, socket) when length(moves) == 0 do
    socket
    |> assign(:clicked, format_card(params))
    |> return_socket()
  end

  def handle_clicked_empty(moves, _params, socket) do
    socket
    |> assign(:game, Game.perform(socket.assigns.game, Enum.fetch!(moves, 0)))
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

  def perform_move_with_unselected_card(moves, socket, params) when length(moves) == 0 do
    assign(socket, :clicked, format_card(params))
  end

  def perform_move_with_unselected_card(moves, socket, _params) do
    socket
    |> assign(:game, Game.perform(socket.assigns.game, Enum.fetch!(moves, 0)))
    |> assign(:clicked, nil)
  end

  def perform_move_with_selected_card(moves, socket, params) when length(moves) == 0 do
    assign(socket, :clicked, format_card(params))
  end

  def perform_move_with_selected_card(moves, socket, _params) do
    socket
    |> assign(:game, Game.perform(socket.assigns.game, Enum.fetch!(moves, 0)))
    |> assign(:clicked, nil)
  end

  def return_socket(socket) do
    {:noreply, socket}
  end

  def handle_deck_click(socket, deck) when length(deck) == 0 do
    socket
    |> return_socket()
  end

  def handle_deck_click(socket, _deck) do
    socket
    |> assign(:game, Game.turn(socket.assigns.game))
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

  def len(nil), do: 0
  def len(list) when is_tuple(list), do: 1
  def len(list) when is_list(list), do: length(list)
end
