defmodule LVSolitaireWeb.LVSolitaireLive do
  @moduledoc """
  Frontend logic
  """
  use Phoenix.LiveView
  alias Solitaire.Game, as: Game
  alias Solitaire.Deck, as: Deck

  @ranks [:a, 2, 3, 4, 5, 6, 7, 8, 9, 10, :j, :q, :k]
  def num_to_rank(rank), do: Enum.at(@ranks, rank - 1)

  def mount(_session, socket) do
    game = Deck.new
           |> Deck.shuffle(Enum.random(0..1))
           |> Game.new
    socket = assign(socket, :game, game)
    socket = assign(socket, :clicked, nil)
    {:ok, socket}
  end

  def render(assigns) do
    LVSolitaireWeb.GameView.render("lv_solitaire.html", assigns)
  end

  def focus?(%{clicked: clicked}, clicked), do: "focus"
  def focus?(%{clicked: _}, _), do: ""

  def possible_moves(socket), do: Game.possible_moves(socket.assigns.game)
  #TODO fix when moveng card valid card to different pile
  def handle_event("click-empty", params, socket) do
    socket
    |> possible_moves()
    |> filter_by_clicked(params, socket.assigns.clicked)
    |> handle_clicked_empty(params, socket)
  end
  def handle_clicked_empty(moves, params, socket) when length(moves) == 0 do
    socket
    |> assign(:clicked, format_card(params))
    |> return_socket()
  end
  def handle_clicked_empty(moves,params, socket) do
    socket
    |> assign(:game, Game.perform(socket.assigns.game, Enum.fetch!(moves, 0)))
    |> assign(:clicked, nil)
    |> return_socket()
  end
  def handle_event("click", params, socket) do
    handle_clicked(params, socket, socket.assigns.clicked)
  end
  def handle_clicked(params, socket, nil) do
    socket
    |> possible_moves()
    |> check_possible_moves(params)
    |> perform_unclicked_move(socket, params)
    |> return_socket()
  end

  def perform_unclicked_move(moves, socket, params) when length(moves) == 0 do
    assign(socket, :clicked, format_card(params))
  end
  def perform_unclicked_move(moves, socket, params) do
    socket
    |> assign(:game, Game.perform(socket.assigns.game, Enum.fetch!(moves, 0)))
    |> assign(:clicked, nil)
  end
  def handle_clicked(params, socket, clicked) do
    socket
    |> possible_moves()
    |> filter_by_clicked(params, clicked)
    |> perform_clicked_move(socket, params)
    |> return_socket()
  end

  def perform_clicked_move(moves, socket, params) when length(moves) == 0 do
    assign(socket, :clicked, format_card(params))
  end 

  def perform_clicked_move(moves, socket, params) do
    socket
    |> assign(:game, Game.perform(socket.assigns.game, Enum.fetch!(moves, 0)))
    |> assign(:clicked, nil)
  end

  def return_socket(socket), do: {:noreply, socket}

  def handle_event("click-deck", _, socket) do
    {{deck, _}, _, _} = socket.assigns.game
    if len(deck) > 0 do
      socket = assign(socket, :game, Game.turn(socket.assigns.game))
      {:noreply, socket}
    else
      {:noreply, socket}
    end
  end
  def handle_event("unselect", _, socket) do
    socket
    |> assign( :clicked, nil)
    |> return_socket()
  end

  def check_possible_moves(moves, %{"index" => index, "pile" => pile_type} = params) do
    moves
    |> Enum.filter(fn {pile_from, from_idx, _pile_to, _to_idx, _card} ->
      from_idx == String.to_integer(index) and Atom.to_string(pile_from) == pile_type
    end)
  end

  def filter_by_clicked(moves, _params, nil), do: moves
  def filter_by_clicked(moves, %{"index" => index, "pile" => pile_type} = params, clicked) do
    moves 
    |> Enum.filter(fn {_pile_from, _from_idx, pile_to, to_idx, card} ->
      to_idx == String.to_integer(index) and Atom.to_string(pile_to) == pile_type and card == clicked
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

