defmodule FlashcardQuizWeb do
  @moduledoc """
  The entrypoint for defining your web interface, such
  as controllers, components, channels, and so on.

  This can be used in your application as:

      use FlashcardQuizWeb, :controller
      use FlashcardQuizWeb, :html

  The definitions below will be executed for every controller,
  component, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below. Instead, define additional modules and import
  those modules here.
  """

  def static_paths, do: ~w(assets fonts images favicon.ico robots.txt)

  def router do
    quote do
      use Phoenix.Router, helpers: false

      # Import common connection and controller functions to use in pipelines
      import Plug.Conn
      import Phoenix.Controller
      import Phoenix.LiveView.Router
    end
  end

  def channel do
    quote do
      use Phoenix.Channel
    end
  end

  def controller do
    quote do
      use Phoenix.Controller, formats: [:html, :json]

      import Plug.Conn

      unquote(verified_routes())
    end
  end

  def live_view do
    quote do
      use Phoenix.LiveView

      unquote(html_helpers())
    end
  end

  def live_component do
    quote do
      use Phoenix.LiveComponent

      unquote(html_helpers())
    end
  end

  def html do
    quote do
      use Phoenix.Component

      # Import convenience functions from controllers
      import Phoenix.Controller,
        only: [get_csrf_token: 0, view_module: 1, view_template: 1]

      # Include general helpers for rendering HTML
      unquote(html_helpers())
    end
  end

  defp html_helpers do
    quote do
      # HTML escaping functionality
      import Phoenix.HTML
      # Core UI components
      import FlashcardQuizWeb.CoreComponents

      # Common modules used in templates
      alias Phoenix.LiveView.JS
      alias FlashcardQuizWeb.Layouts

      # Routes generation with the ~p sigil
      unquote(verified_routes())
    end
  end

  def verified_routes do
    quote do
      use Phoenix.VerifiedRoutes,
        endpoint: FlashcardQuizWeb.Endpoint,
        router: FlashcardQuizWeb.Router,
        statics: FlashcardQuizWeb.static_paths()
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/live_view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end

  @doc """
  Processes markdown content with Earmark and enhances Elixir code blocks with Makeup syntax highlighting.
  """
  def process_markdown(content) do
    content
    |> Earmark.as_html!()
    |> enhance_elixir_code_blocks()
    |> Phoenix.HTML.raw()
  end

  defp enhance_elixir_code_blocks(html) do
    # Pattern to match <code class="elixir">...</code> blocks
    pattern = ~r/<code class="elixir">(.*?)<\/code>/s

    Regex.replace(pattern, html, fn _, code_content ->
      # Decode HTML entities before highlighting
      code_content
      |> String.replace("&lt;", "<")
      |> String.replace("&gt;", ">")
      |> String.replace("&amp;", "&")
      |> String.replace("&quot;", "\"")
      |> String.replace("&#39;", "'")
      |> Makeup.highlight(lexer: Makeup.Lexers.ElixirLexer)
    end)
  end
end
