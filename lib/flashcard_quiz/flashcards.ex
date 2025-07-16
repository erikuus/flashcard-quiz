defmodule FlashcardQuiz.Flashcards do
  @moduledoc """
  The Flashcards context.
  """

  import Ecto.Query, warn: false
  alias FlashcardQuiz.Repo

  alias FlashcardQuiz.Flashcards.Flashcard
  alias FlashcardQuiz.Flashcards.Pack

  @doc """
  Returns the list of packs.

  ## Examples

      iex> list_packs()
      [%Pack{}, ...]

  """
  def list_packs do
    Repo.all(Pack)
  end

  @doc """
  Gets a single pack.

  Raises `Ecto.NoResultsError` if the Pack does not exist.

  ## Examples

      iex> get_pack!(123)
      %Pack{}

      iex> get_pack!(456)
      ** (Ecto.NoResultsError)

  """
  def get_pack!(id), do: Repo.get!(Pack, id)

  @doc """
  Creates a pack.

  ## Examples

      iex> create_pack(%{field: value})
      {:ok, %Pack{}}

      iex> create_pack(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_pack(attrs \\ %{}) do
    %Pack{}
    |> Pack.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a pack.

  ## Examples

      iex> update_pack(pack, %{field: new_value})
      {:ok, %Pack{}}

      iex> update_pack(pack, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_pack(%Pack{} = pack, attrs) do
    pack
    |> Pack.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a pack.

  ## Examples

      iex> delete_pack(pack)
      {:ok, %Pack{}}

      iex> delete_pack(pack)
      {:error, %Ecto.Changeset{}}

  """
  def delete_pack(%Pack{} = pack) do
    Repo.delete(pack)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking pack changes.

  ## Examples

      iex> change_pack(pack)
      %Ecto.Changeset

  """
  def change_pack(%Pack{} = pack, attrs \\ %{}) do
    Pack.changeset(pack, attrs)
  end

  @doc """
  Returns the list of flashcards, optionally filtered by pack.

  ## Examples

      iex> list_flashcards()
      [%Flashcard{}, ...]

      iex> list_flashcards(pack_id: 1)
      [%Flashcard{}, ...]

  """
  def list_flashcards(opts \\ []) do
    query = from(f in Flashcard, preload: [:pack])

    case Keyword.get(opts, :pack_id) do
      nil ->
        Repo.all(query)

      pack_id ->
        query
        |> where([f], f.pack_id == ^pack_id)
        |> Repo.all()
    end
  end

  @doc """
  Gets a single flashcard.

  Raises `Ecto.NoResultsError` if the Flashcard does not exist.

  ## Examples

      iex> get_flashcard!(123)
      %Flashcard{}

      iex> get_flashcard!(456)
      ** (Ecto.NoResultsError)

  """
  def get_flashcard!(id), do: Repo.get!(Flashcard, id) |> Repo.preload(:pack)

  @doc """
  Creates a flashcard.

  ## Examples

      iex> create_flashcard(%{field: value})
      {:ok, %Flashcard{}}

      iex> create_flashcard(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_flashcard(attrs \\ %{}) do
    %Flashcard{}
    |> Flashcard.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a flashcard.

  ## Examples

      iex> update_flashcard(flashcard, %{field: new_value})
      {:ok, %Flashcard{}}

      iex> update_flashcard(flashcard, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_flashcard(%Flashcard{} = flashcard, attrs) do
    flashcard
    |> Flashcard.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a flashcard.

  ## Examples

      iex> delete_flashcard(flashcard)
      {:ok, %Flashcard{}}

      iex> delete_flashcard(flashcard)
      {:error, %Ecto.Changeset{}}

  """
  def delete_flashcard(%Flashcard{} = flashcard) do
    Repo.delete(flashcard)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking flashcard changes.

  ## Examples

      iex> change_flashcard(flashcard)
      %Ecto.Changeset{data: %Flashcard{}}

  """
  def change_flashcard(%Flashcard{} = flashcard, attrs \\ %{}) do
    Flashcard.changeset(flashcard, attrs)
  end
end
