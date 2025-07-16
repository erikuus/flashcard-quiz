# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     FlashcardQuiz.Repo.insert!(%FlashcardQuiz.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias FlashcardQuiz.Flashcards
alias FlashcardQuiz.Repo

# Clear existing data
Repo.delete_all(FlashcardQuiz.Flashcards.Flashcard)
Repo.delete_all(FlashcardQuiz.Flashcards.Pack)

# Create packs
{:ok, elixir_pack} = Flashcards.create_pack(%{name: "Elixir Basics"})
{:ok, phoenix_pack} = Flashcards.create_pack(%{name: "Phoenix Specifics"})

# Create sample Elixir flashcards
{:ok, _} =
  Flashcards.create_flashcard(%{
    front: "How do you sum all values in a list?",
    back: """
    ```elixir
    Enum.reduce([2, 4, 6], 0, &+/2)
    ```

    Or (expanded):

    ```elixir
    Enum.reduce([2, 4, 6], 0, fn x, acc -> x + acc end)
    ```
    """,
    pack_id: elixir_pack.id
  })

{:ok, _} =
  Flashcards.create_flashcard(%{
    front: "How do you pattern match a list?",
    back: """
    ```elixir
    [head | tail] = [1, 2, 3, 4]
    # head = 1, tail = [2, 3, 4]
    ```
    """,
    pack_id: elixir_pack.id
  })

# Create sample Phoenix flashcards
{:ok, _} =
  Flashcards.create_flashcard(%{
    front: "How do you create a LiveView route?",
    back: """
    ```elixir
    live "/path", MyLive
    ```
    """,
    pack_id: phoenix_pack.id
  })

IO.puts(
  "Seeded #{Enum.count(Flashcards.list_packs())} packs and #{Enum.count(Flashcards.list_flashcards())} flashcards!"
)
