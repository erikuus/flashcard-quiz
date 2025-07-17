defmodule FlashcardQuizWeb.QuizLive do
  use FlashcardQuizWeb, :live_view

  alias FlashcardQuiz.Flashcards

  @impl true
  def mount(params, _session, socket) do
    pack_id = params["pack_id"]

    packs = Flashcards.list_packs()

    flashcards =
      if pack_id do
        Flashcards.list_flashcards(pack_id: pack_id)
      else
        Flashcards.list_flashcards()
      end

    selected_pack =
      if pack_id do
        Enum.find(packs, &(&1.id == String.to_integer(pack_id)))
      else
        nil
      end

    {:ok,
     socket
     |> assign(:flashcards, flashcards)
     |> assign(:packs, packs)
     |> assign(:selected_pack, selected_pack)
     |> assign(:current_index, 0)
     |> assign(:showing_answer, false)
     |> assign(:draft_answer, "")
     |> assign(:score_correct, 0)
     |> assign(:score_total, 0)}
  end

  @impl true
  def handle_event("flip_card", _params, socket) do
    {:noreply, assign(socket, :showing_answer, true)}
  end

  def handle_event("hide_answer", _params, socket) do
    {:noreply, assign(socket, :showing_answer, false)}
  end

  def handle_event("next_card", _params, socket) do
    new_index = min(socket.assigns.current_index + 1, length(socket.assigns.flashcards) - 1)

    {:noreply,
     socket
     |> assign(:current_index, new_index)
     |> assign(:showing_answer, false)
     |> assign(:draft_answer, "")}
  end

  def handle_event("previous_card", _params, socket) do
    new_index = max(socket.assigns.current_index - 1, 0)

    {:noreply,
     socket
     |> assign(:current_index, new_index)
     |> assign(:showing_answer, false)
     |> assign(:draft_answer, "")}
  end

  def handle_event("mark_correct", _params, socket) do
    {:noreply,
     socket
     |> assign(:score_correct, socket.assigns.score_correct + 1)
     |> assign(:score_total, socket.assigns.score_total + 1)}
  end

  def handle_event("mark_incorrect", _params, socket) do
    {:noreply, assign(socket, :score_total, socket.assigns.score_total + 1)}
  end

  def handle_event("reset_quiz", _params, socket) do
    {:noreply,
     socket
     |> assign(:current_index, 0)
     |> assign(:showing_answer, false)
     |> assign(:draft_answer, "")
     |> assign(:score_correct, 0)
     |> assign(:score_total, 0)}
  end

  def handle_event("update_draft", %{"draft" => draft}, socket) do
    {:noreply, assign(socket, :draft_answer, draft)}
  end

  def handle_event("select_pack", %{"pack_id" => pack_id}, socket) do
    if pack_id == "" do
      # All packs
      {:noreply, push_navigate(socket, to: "/")}
    else
      {:noreply, push_navigate(socket, to: "/quiz?pack_id=#{pack_id}")}
    end
  end

  def handle_event("start_quiz", _params, socket) do
    if socket.assigns.selected_pack do
      {:noreply, push_navigate(socket, to: "/quiz?pack_id=#{socket.assigns.selected_pack.id}")}
    else
      {:noreply, push_navigate(socket, to: "/quiz")}
    end
  end

  defp current_flashcard(flashcards, index) do
    Enum.at(flashcards, index)
  end

  defp has_previous?(index), do: index > 0
  defp has_next?(flashcards, index), do: index < length(flashcards) - 1

  # Unused helper function kept for compatibility
  defp current_card(flashcards, index) do
    Enum.at(flashcards, index)
  end
end
