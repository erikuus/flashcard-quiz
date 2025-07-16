defmodule FlashcardQuizWeb.PacksLive do
  use FlashcardQuizWeb, :live_view

  alias FlashcardQuiz.Flashcards
  alias FlashcardQuiz.Flashcards.Pack

  def mount(_params, _session, socket) do
    packs = Flashcards.list_packs()
    changeset = Flashcards.change_pack(%Pack{})

    {:ok,
     socket
     |> assign(:packs, packs)
     |> assign(:form, to_form(changeset))
     |> assign(:editing_id, nil)
     |> assign(:packs_empty?, packs == [])}
  end

  def handle_event("validate", %{"pack" => pack_params}, socket) do
    changeset =
      %Pack{}
      |> Flashcards.change_pack(pack_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, form: to_form(changeset))}
  end

  def handle_event("save", %{"pack" => pack_params}, socket) do
    case socket.assigns.editing_id do
      nil -> create_pack(socket, pack_params)
      id -> update_pack(socket, id, pack_params)
    end
  end

  def handle_event("edit", %{"id" => id}, socket) do
    pack = Flashcards.get_pack!(id)
    changeset = Flashcards.change_pack(pack)

    {:noreply,
     socket
     |> assign(:form, to_form(changeset))
     |> assign(:editing_id, String.to_integer(id))}
  end

  def handle_event("cancel", _params, socket) do
    changeset = Flashcards.change_pack(%Pack{})

    {:noreply,
     socket
     |> assign(:form, to_form(changeset))
     |> assign(:editing_id, nil)}
  end

  def handle_event("delete", %{"id" => id}, socket) do
    pack = Flashcards.get_pack!(id)
    {:ok, _} = Flashcards.delete_pack(pack)

    packs = Flashcards.list_packs()

    {:noreply,
     socket
     |> assign(:packs, packs)
     |> assign(:packs_empty?, packs == [])
     |> put_flash(:info, "Pack deleted successfully")}
  end

  defp create_pack(socket, pack_params) do
    case Flashcards.create_pack(pack_params) do
      {:ok, _pack} ->
        changeset = Flashcards.change_pack(%Pack{})
        packs = Flashcards.list_packs()

        {:noreply,
         socket
         |> assign(:form, to_form(changeset))
         |> assign(:packs, packs)
         |> assign(:packs_empty?, false)
         |> put_flash(:info, "Pack created successfully")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp update_pack(socket, id, pack_params) do
    pack = Flashcards.get_pack!(id)

    case Flashcards.update_pack(pack, pack_params) do
      {:ok, _pack} ->
        changeset = Flashcards.change_pack(%Pack{})
        packs = Flashcards.list_packs()

        {:noreply,
         socket
         |> assign(:form, to_form(changeset))
         |> assign(:packs, packs)
         |> assign(:editing_id, nil)
         |> put_flash(:info, "Pack updated successfully")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end
end
