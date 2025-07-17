defmodule FlashcardQuizWeb.PackSelectionLive do
  use FlashcardQuizWeb, :live_view

  alias FlashcardQuiz.Flashcards

  def mount(_params, _session, socket) do
    packs = Flashcards.list_packs()

    {:ok,
     socket
     |> assign(:packs, packs)
     |> assign(:packs_empty?, packs == [])}
  end

  def handle_event("select_pack", %{"pack_id" => ""}, socket) do
    {:noreply, push_navigate(socket, to: ~p"/quiz")}
  end

  def handle_event("select_pack", %{"pack_id" => pack_id}, socket) do
    {:noreply, push_navigate(socket, to: ~p"/quiz?pack_id=#{pack_id}")}
  end

  def handle_event("start_all_packs", _params, socket) do
    {:noreply, push_navigate(socket, to: ~p"/quiz")}
  end

  def handle_event("start_pack", %{"id" => pack_id}, socket) do
    {:noreply, push_navigate(socket, to: ~p"/quiz?pack_id=#{pack_id}")}
  end
end
