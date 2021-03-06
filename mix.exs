defmodule Behold.Mixfile do
  use Mix.Project

  def project do
    [
      app: :behold,
      version: "0.0.1",
      elixir: "~> 1.4",
      elixirc_paths: elixirc_paths(Mix.env),
      compilers: [:phoenix, :gettext] ++ Mix.compilers,
      start_permanent: Mix.env == :prod,
      aliases: aliases(),
      deps: deps(),
      releases: [
        behold_api: [
          include_erts: true,
          version: "0.0.1",
          include_executables_for: [:unix],
          applications: [
            behold: :permanent
          ]
        ]
      ]
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Behold.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.3.4"},
      {:phoenix_pubsub, "~> 1.0"},
      {:phoenix_ecto, "~> 3.2"},
      {:ecto_sql, "~> 3.3"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 2.10"},
      {:phoenix_live_reload, "~> 1.0", only: :dev},
      {:gettext, "~> 0.11"},
      {:cowboy, "~> 1.0"},
      {:plug_cowboy, "~> 1.0"},
      {:ecto_enum, "~> 1.4"},
      {:httpoison, "~> 1.6"},
      {:bamboo, "~> 1.4"},
      {:timex, "~> 3.5"},
      {:cors_plug, "~> 1.5"},
      {:dns, git: "https://github.com/silverp1/elixir-dns"},
      {:ping, git: "https://github.com/silverp1/elixir-ping"},
      {:sentry, "~> 7.0"},
      {:jason, "~> 1.1"},
      {:prometheus_ex, "~> 3.0"},
      {:logglix, git: "https://github.com/silverp1/logglix"},
      {:prometheus_plugs, "~> 1.1"},
      {:mox, "~> 1.0", only: :test},
      {:libcluster, "~> 3.2"},
      {:gelfx, "~> 1.0"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      "test": ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end
