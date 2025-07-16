defmodule FlashcardQuizWeb.QuizLive do
  use FlashcardQuizWeb, :live_view

  alias FlashcardQuiz.Flashcards

  @impl true
  def mount(params, _session, socket) do
    pack_id = params["pack_id"]

    flashcards =
      if pack_id do
        Flashcards.list_flashcards(pack_id: String.to_integer(pack_id))
      else
        Flashcards.list_flashcards()
      end

    if flashcards == [] do
      {:ok,
       socket
       |> put_flash(:info, "No flashcards available. Create some flashcards first!")
       |> push_navigate(to: "/manage")}
    else
      {:ok,
       socket
       |> assign(:pack_id, pack_id)
       |> assign(:flashcards, flashcards)
       |> assign(:current_index, 0)
       |> assign(:show_answer, false)
       |> assign(:score, 0)
       |> assign(:answered_count, 0)
       |> assign(:current_card, hd(flashcards))}
    end
  end

  @impl true
  def handle_event("flip_card", _params, socket) do
    {:noreply, assign(socket, :show_answer, !socket.assigns.show_answer)}
  end

  @impl true
  def handle_event("mark_correct", _params, socket) do
    new_score = socket.assigns.score + 1
    new_answered_count = socket.assigns.answered_count + 1

    socket =
      socket
      |> assign(:score, new_score)
      |> assign(:answered_count, new_answered_count)
      |> next_card()

    {:noreply, socket}
  end

  @impl true
  def handle_event("mark_incorrect", _params, socket) do
    new_answered_count = socket.assigns.answered_count + 1

    socket =
      socket
      |> assign(:answered_count, new_answered_count)
      |> next_card()

    {:noreply, socket}
  end

  @impl true
  def handle_event("next_card", _params, socket) do
    {:noreply, next_card(socket)}
  end

  @impl true
  def handle_event("previous_card", _params, socket) do
    {:noreply, previous_card(socket)}
  end

  @impl true
  def handle_event("reset_quiz", _params, socket) do
    {:noreply,
     socket
     |> assign(:current_index, 0)
     |> assign(:show_answer, false)
     |> assign(:score, 0)
     |> assign(:answered_count, 0)
     |> assign(:current_card, hd(socket.assigns.flashcards))}
  end

  defp next_card(socket) do
    flashcards = socket.assigns.flashcards
    current_index = socket.assigns.current_index
    new_index = min(current_index + 1, length(flashcards) - 1)

    socket
    |> assign(:current_index, new_index)
    |> assign(:show_answer, false)
    |> assign(:current_card, Enum.at(flashcards, new_index))
  end

  defp previous_card(socket) do
    flashcards = socket.assigns.flashcards
    current_index = socket.assigns.current_index
    new_index = max(current_index - 1, 0)

    socket
    |> assign(:current_index, new_index)
    |> assign(:show_answer, false)
    |> assign(:current_card, Enum.at(flashcards, new_index))
  end

  defp progress_percentage(current_index, total_cards) do
    if total_cards > 0 do
      round((current_index + 1) / total_cards * 100)
    else
      0
    end
  end

  defp markdown_to_html(text) do
    text
    |> String.replace(
      ~r/```elixir\n(.*?)\n```/s,
      "<pre class=\"bg-slate-100 p-4 rounded-lg text-sm font-mono overflow-x-auto\"><code class=\"language-elixir\">\\1</code></pre>"
    )
    |> String.replace(
      ~r/```(\w+)?\n(.*?)\n```/s,
      "<pre class=\"bg-slate-100 p-4 rounded-lg text-sm font-mono overflow-x-auto\"><code>\\2</code></pre>"
    )
    |> String.replace(
      ~r/`([^`]+)`/,
      "<code class=\"bg-slate-100 px-2 py-1 rounded text-sm font-mono\">\\1</code>"
    )
    |> String.replace(~r/\*\*(.*?)\*\*/, "<strong>\\1</strong>")
    |> String.replace(~r/\*(.*?)\*/, "<em>\\1</em>")
    |> String.replace("\n", "<br>")
  end
end
