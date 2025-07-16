defmodule FlashcardQuizWeb.ManageLive do
  use FlashcardQuizWeb, :live_view

  alias FlashcardQuiz.Flashcards
  alias FlashcardQuiz.Flashcards.Flashcard

  def mount(_params, _session, socket) do
    flashcards = Flashcards.list_flashcards()
    changeset = Flashcards.change_flashcard(%Flashcard{})

    {:ok,
     socket
     |> assign(:flashcards, flashcards)
     |> assign(:form, to_form(changeset))
     |> assign(:editing_id, nil)
     |> assign(:flashcards_empty?, flashcards == [])}
  end

  def handle_event("validate", %{"flashcard" => flashcard_params}, socket) do
    changeset =
      %Flashcard{}
      |> Flashcards.change_flashcard(flashcard_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, form: to_form(changeset))}
  end

  def handle_event("save", %{"flashcard" => flashcard_params}, socket) do
    case socket.assigns.editing_id do
      nil -> create_flashcard(socket, flashcard_params)
      id -> update_flashcard(socket, id, flashcard_params)
    end
  end

  def handle_event("edit", %{"id" => id}, socket) do
    flashcard = Flashcards.get_flashcard!(id)
    changeset = Flashcards.change_flashcard(flashcard)

    {:noreply,
     socket
     |> assign(:form, to_form(changeset))
     |> assign(:editing_id, String.to_integer(id))}
  end

  def handle_event("cancel", _params, socket) do
    changeset = Flashcards.change_flashcard(%Flashcard{})

    {:noreply,
     socket
     |> assign(:form, to_form(changeset))
     |> assign(:editing_id, nil)}
  end

  def handle_event("delete", %{"id" => id}, socket) do
    flashcard = Flashcards.get_flashcard!(id)
    {:ok, _} = Flashcards.delete_flashcard(flashcard)

    flashcards = Flashcards.list_flashcards()

    {:noreply,
     socket
     |> assign(:flashcards, flashcards)
     |> assign(:flashcards_empty?, flashcards == [])
     |> put_flash(:info, "Flashcard deleted successfully")}
  end

  defp create_flashcard(socket, flashcard_params) do
    case Flashcards.create_flashcard(flashcard_params) do
      {:ok, _flashcard} ->
        changeset = Flashcards.change_flashcard(%Flashcard{})
        flashcards = Flashcards.list_flashcards()

        {:noreply,
         socket
         |> assign(:form, to_form(changeset))
         |> assign(:flashcards, flashcards)
         |> assign(:flashcards_empty?, false)
         |> put_flash(:info, "Flashcard created successfully")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp update_flashcard(socket, id, flashcard_params) do
    flashcard = Flashcards.get_flashcard!(id)

    case Flashcards.update_flashcard(flashcard, flashcard_params) do
      {:ok, _flashcard} ->
        changeset = Flashcards.change_flashcard(%Flashcard{})
        flashcards = Flashcards.list_flashcards()

        {:noreply,
         socket
         |> assign(:form, to_form(changeset))
         |> assign(:flashcards, flashcards)
         |> assign(:editing_id, nil)
         |> put_flash(:info, "Flashcard updated successfully")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end
end
