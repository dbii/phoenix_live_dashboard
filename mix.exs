defmodule Phoenix.LiveDashboard.MixProject do
  use Mix.Project

  @version "0.1.0"

  def project do
    [
      app: :phoenix_live_dashboard,
      version: @version,
      elixir: "~> 1.7",
      compilers: [:phoenix] ++ Mix.compilers(),
      elixirc_paths: elixirc_paths(Mix.env()),
      deps: deps(),
      package: package(),
      docs: docs(),
      homepage_url: "http://www.phoenixframework.org",
      description: "Real-time performance monitor and tracer for Phoenix"
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {Phoenix.LiveDashboard.Application, []},
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:phoenix_live_view, "~> 0.8.0", github: "phoenixframework/phoenix_live_view"},
      {:telemetry_metrics, "~> 0.4.0"},
      {:ex_doc, "~> 0.21", only: :docs},
      {:jason, "~> 1.0", optional: true},
      {:floki, "~> 0.24.0", only: :test}
    ]
  end

  defp docs do
    [
      main: "Phoenix.LiveDashboard",
      source_ref: "v#{@version}",
      source_url: "https://github.com/phoenixframework/phoenix_live_dashboard",
      extra_section: "GUIDES",
      extras: extras()
    ]
  end

  defp extras do
    [
      "guides/metrics.md"
    ]
  end

  defp package do
    [
      maintainers: ["Michael Crumm", "Chris McCord", "José Valim"],
      licenses: ["MIT"],
      links: %{github: "https://github.com/phoenixframework/phoenix_live_dashboard"},
      files:
        ~w(assets/css assets/js lib priv) ++
          ~w(CHANGELOG.md LICENSE.md mix.exs package.json README.md)
    ]
  end
end
