defmodule Ra.Mixfile do
  use Mix.Project

  def project do
    [app: :ra,
     version: "0.3.2",
     elixir: "~> 1.0",
     package: package(),
     docs: [readme: true, main: "README.md"],
     description: """
      Ra is a framework for building command line applications.
     """,
     deps: deps()]
  end

  def application do
    [applications: [:logger]]
  end

  defp deps do
    [{:power_assert, "~> 0.0", only: :test},
     {:ex_doc, "~> 0.11.4", only: :dev},
     {:earmark, "~> 0.2.1", only: :dev}]
  end

  defp package do
    %{
      licenses: ["MIT"],
      maintainers: ["Norbert Melzer"],
      contributors: ["Benny Hallett", "Norbert Melzer"],
      links: %{
        "Github" => "https://github.com/NobbZ/ra",
        "Upstream project" => "https://github.com/bennyhallet/anubis"
      }
    }
  end
end
