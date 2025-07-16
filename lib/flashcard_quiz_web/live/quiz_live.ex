defmodule FlashcardQuizWeb.QuizLive do
  use FlashcardQuizWeb, :live_view

  alias FlashcardQuiz.Flashcards

  @topic "flashcard_quiz"

  def mount(_params, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(FlashcardQuiz.PubSub, @topic)
    end

    flashcards = Flashcards.list_flashcards()

    {:ok,
     socket
     |> assign(:flashcards, flashcards)
     |> assign(:current_index, 0)
     |> assign(:score, 0)
     |> assign(:total_answered, 0)
     |> assign(:showing_answer, false)
     |> assign(:quiz_complete, false)
     |> assign(:flashcards_empty?, flashcards == [])}
  end

  def handle_event("flip_card", _params, socket) do
    {:noreply, assign(socket, :showing_answer, !socket.assigns.showing_answer)}
  end

  def handle_event("mark_correct", _params, socket) do
    new_score = socket.assigns.score + 1
    new_total = socket.assigns.total_answered + 1

    # Broadcast score update
    Phoenix.PubSub.broadcast(FlashcardQuiz.PubSub, @topic, {:score_update, new_score, new_total})

    {:noreply,
     socket
     |> assign(:score, new_score)
     |> assign(:total_answered, new_total)
     |> assign(:showing_answer, false)
     |> next_card()}
  end

  def handle_event("mark_incorrect", _params, socket) do
    new_total = socket.assigns.total_answered + 1

    # Broadcast score update
    Phoenix.PubSub.broadcast(
      FlashcardQuiz.PubSub,
      @topic,
      {:score_update, socket.assigns.score, new_total}
    )

    {:noreply,
     socket
     |> assign(:total_answered, new_total)
     |> assign(:showing_answer, false)
     |> next_card()}
  end

  def handle_event("next_card", _params, socket) do
    {:noreply, next_card(socket)}
  end

  def handle_event("previous_card", _params, socket) do
    {:noreply, previous_card(socket)}
  end

  def handle_event("reset_quiz", _params, socket) do
    {:noreply,
     socket
     |> assign(:current_index, 0)
     |> assign(:score, 0)
     |> assign(:total_answered, 0)
     |> assign(:showing_answer, false)
     |> assign(:quiz_complete, false)}
  end

  def handle_info({:score_update, score, total}, socket) do
    {:noreply,
     socket
     |> assign(:score, score)
     |> assign(:total_answered, total)}
  end

  defp next_card(socket) do
    flashcards = socket.assigns.flashcards
    current_index = socket.assigns.current_index

    if current_index + 1 >= length(flashcards) do
      assign(socket, :quiz_complete, true)
    else
      assign(socket, :current_index, current_index + 1)
    end
  end

  defp previous_card(socket) do
    current_index = socket.assigns.current_index

    if current_index > 0 do
      assign(socket, :current_index, current_index - 1)
    else
      socket
    end
  end

  defp current_card(flashcards, index) do

  defp markdown_to_html(text) do
    text
    |> String.replace(~r/```elixir
(.*?)
```/s, "<pre class="bg-slate-100 p-4 rounded-lg overflow-x-auto"><code class="language-elixir text-sm">\1</code></pre>")
    |> String.replace(~r/```(w+)?
(.*?)
```/s, "<pre class="bg-slate-100 p-4 rounded-lg overflow-x-auto"><code class="text-sm">\2</code></pre>")
    |> String.replace(~r/`([^`]+)`/, "<code class="bg-slate-100 px-1 py-0.5 rounded text-sm">\1</code>")
    |> String.replace(~r/**(.*?)**/, "<strong>\1</strong>")
    |> String.replace(~r/*(.*?)*/, "<em>\1</em>")
    |> String.replace("
", "<br>")
    Enum.at(flashcards, index)
  end
end
