defmodule LVSolitaireWeb.LVSolitaireLive do
  @moduledoc """
  Frontend logic
  """
  use Phoenix.LiveView
  alias Solitaire.Game, as: Game
  alias Solitaire.Foundation, as: Foundation
  alias Solitaire.Tableau, as: Tableau
  alias Solitaire.Stock, as: Stock
  alias Solitaire.Deck, as: Deck
  alias Solitaire.Cards, as: Cards
  require Logger

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

  #TODO need this when multiple moves possible for A
  #TODO fix when moveng card valid card to different pile
  def handle_event("click-empty", params, socket) do
    IO.inspect(params)
    clicked = socket.assigns.clicked
    moves = socket.assigns.game
          |> Game.possible_moves()
          |> IO.inspect()
          |> filter_by_clicked(params, clicked)
          |> IO.inspect()
          |> check_possible_moves(params)
          |> IO.inspect()
    if len(moves) == 1 do
      socket = assign(socket, :game, Game.perform(socket.assigns.game, Enum.fetch!(moves, 0)))
      socket = assign(socket, :clicked, nil)
      {:noreply, socket}
    else
      socket = assign(socket, :clicked, format_card(params))
      {:noreply, socket}
    end
  end
  def handle_event("click", params, socket) do
    handle_clicked(params, socket, socket.assigns.clicked)
  end
  def handle_clicked(params, socket, nil) do
    moves = socket.assigns.game
          |> Game.possible_moves()
          |> check_possible_moves(params)
    if len(moves) == 1 do
      socket = assign(socket, :game, Game.perform(socket.assigns.game, Enum.fetch!(moves, 0)))
      socket = assign(socket, :clicked, nil)
      {:noreply, socket}
    else
      socket = assign(socket, :clicked, format_card(params))
      {:noreply, socket}
    end
  end
  def handle_clicked(params, socket, clicked) do
    moves = socket.assigns.game
          |> Game.possible_moves()
          |> filter_by_clicked(params, clicked)
    if len(moves) == 1 do
      socket = assign(socket, :game, Game.perform(socket.assigns.game, Enum.fetch!(moves, 0)))
      socket = assign(socket, :clicked, nil)
      {:noreply, socket}
    else
      socket = assign(socket, :clicked, format_card(params))
      {:noreply, socket}
    end
  end
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
    socket = assign(socket, :clicked, nil)
    {:noreply, socket}
  end

  def check_possible_moves(moves, %{"rank" => rank, "suit" => suit, "index" => index, "pile" => pile_type} = params) do
    moves
    |> Enum.filter(fn {pile_from, f_idx, pile_to, t_idx, _card} ->
      f_idx == String.to_integer(index) and Atom.to_string(pile_from) == pile_type
    end)
  end

  def filter_by_clicked(moves, _params, nil), do: moves
  def filter_by_clicked(moves, %{"index" => index, "pile" => pile_type} = params, clicked) do
    moves 
    |> Enum.filter(fn {pile_from, f_idx, pile_to, t_idx, card} ->
      IO.inspect(clicked)
      IO.inspect(card)
      IO.inspect(params)
      IO.inspect(moves)
      IO.inspect({t_idx , String.to_integer(index) , Atom.to_string(pile_to) , pile_type , card , clicked} )
      IO.inspect({t_idx == String.to_integer(index) , Atom.to_string(pile_to) == pile_type , card == clicked} )
      t_idx == String.to_integer(index) and Atom.to_string(pile_to) == pile_type and card == clicked
    end)
  end
  def format_card(%{"rank" => rank, "suit" => suit}) do
      {String.to_existing_atom(suit), String.to_integer(rank)}
  end
  def len(nil), do: 0
  def len(list) when is_tuple(list), do: 1
  def len(list) when is_list(list), do: length(list)
end

