defmodule FlashcardQuizWeb.ManageLive do
  use FlashcardQuizWeb, :live_view

  alias FlashcardQuiz.Flashcards
  alias FlashcardQuiz.Flashcards.Flashcard

  def mount(params, _session, socket) do
    pack_id = params["pack_id"]

    flashcards =
      if pack_id,
        do: Flashcards.list_flashcards(pack_id: pack_id),
        else: Flashcards.list_flashcards()

    packs = Flashcards.list_packs()
    changeset = Flashcards.change_flashcard(%Flashcard{})

    # Set default pack_id if filtering by pack
    changeset =
      if pack_id do
        changeset |> Ecto.Changeset.put_change(:pack_id, String.to_integer(pack_id))
      else
        changeset
      end

    {:ok,
     socket
     |> assign(:flashcards, flashcards)
     |> assign(:packs, packs)
     |> assign(:form, to_form(changeset))
     |> assign(:editing_id, nil)
     |> assign(:show_modal, false)
     |> assign(:current_pack_id, pack_id)
     |> assign(:flashcards_empty?, flashcards == [])}
  end

  def handle_params(params, _url, socket) do
    pack_id = params["pack_id"]

    flashcards =
      if pack_id,
        do: Flashcards.list_flashcards(pack_id: pack_id),
        else: Flashcards.list_flashcards()

    {:noreply,
     socket
     |> assign(:flashcards, flashcards)
     |> assign(:current_pack_id, pack_id)
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

  def handle_event("new_flashcard", _params, socket) do
    changeset = Flashcards.change_flashcard(%Flashcard{})

    changeset =
      if socket.assigns.current_pack_id do
        changeset
        |> Ecto.Changeset.put_change(:pack_id, String.to_integer(socket.assigns.current_pack_id))
      else
        changeset
      end

    {:noreply,
     socket
     |> assign(:form, to_form(changeset))
     |> assign(:editing_id, nil)
     |> assign(:show_modal, true)}
  end

  def handle_event("edit", %{"id" => id}, socket) do
    flashcard = Flashcards.get_flashcard!(id)
    changeset = Flashcards.change_flashcard(flashcard)

    {:noreply,
     socket
     |> assign(:form, to_form(changeset))
     |> assign(:editing_id, String.to_integer(id))
     |> assign(:show_modal, true)}
  end

  def handle_event("cancel", _params, socket) do
    changeset = Flashcards.change_flashcard(%Flashcard{})

    # Restore default pack_id if filtering by pack
    changeset =
      if socket.assigns.current_pack_id do
        changeset
        |> Ecto.Changeset.put_change(:pack_id, String.to_integer(socket.assigns.current_pack_id))
      else
        changeset
      end

    {:noreply,
     socket
     |> assign(:form, to_form(changeset))
     |> assign(:editing_id, nil)
     |> assign(:show_modal, false)}
  end

  def handle_event("delete", %{"id" => id}, socket) do
    flashcard = Flashcards.get_flashcard!(id)
    {:ok, _} = Flashcards.delete_flashcard(flashcard)

    pack_id = socket.assigns.current_pack_id

    flashcards =
      if pack_id,
        do: Flashcards.list_flashcards(pack_id: pack_id),
        else: Flashcards.list_flashcards()

    {:noreply,
     socket
     |> assign(:flashcards, flashcards)
     |> assign(:flashcards_empty?, flashcards == [])
     |> put_flash(:info, "Flashcard deleted successfully")}
  end

  def handle_event("close_modal", _params, socket) do
    changeset = Flashcards.change_flashcard(%Flashcard{})

    changeset =
      if socket.assigns.current_pack_id do
        changeset
        |> Ecto.Changeset.put_change(:pack_id, String.to_integer(socket.assigns.current_pack_id))
      else
        changeset
      end

    {:noreply,
     socket
     |> assign(:form, to_form(changeset))
     |> assign(:editing_id, nil)
     |> assign(:show_modal, false)}
  end

  defp create_flashcard(socket, flashcard_params) do
    case Flashcards.create_flashcard(flashcard_params) do
      {:ok, _flashcard} ->
        changeset = Flashcards.change_flashcard(%Flashcard{})

        # Restore default pack_id if filtering by pack
        changeset =
          if socket.assigns.current_pack_id do
            changeset
            |> Ecto.Changeset.put_change(
              :pack_id,
              String.to_integer(socket.assigns.current_pack_id)
            )
          else
            changeset
          end

        pack_id = socket.assigns.current_pack_id

        flashcards =
          if pack_id,
            do: Flashcards.list_flashcards(pack_id: pack_id),
            else: Flashcards.list_flashcards()

        {:noreply,
         socket
         |> assign(:form, to_form(changeset))
         |> assign(:flashcards, flashcards)
         |> assign(:flashcards_empty?, false)
         |> assign(:show_modal, false)
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

        # Restore default pack_id if filtering by pack
        changeset =
          if socket.assigns.current_pack_id do
            changeset
            |> Ecto.Changeset.put_change(
              :pack_id,
              String.to_integer(socket.assigns.current_pack_id)
            )
          else
            changeset
          end

        pack_id = socket.assigns.current_pack_id

        flashcards =
          if pack_id,
            do: Flashcards.list_flashcards(pack_id: pack_id),
            else: Flashcards.list_flashcards()

        {:noreply,
         socket
         |> assign(:form, to_form(changeset))
         |> assign(:flashcards, flashcards)
         |> assign(:editing_id, nil)
         |> assign(:show_modal, false)
         |> put_flash(:info, "Flashcard updated successfully")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end
end
