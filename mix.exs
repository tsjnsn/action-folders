defmodule ActionFolders.Mixfile do
  use Mix.Project

  def project do
    [app: :action_folders,
     version: "0.0.1",
     elixir: "~> 1.0.0",
     deps: deps]
  end

  def application do
    [applications: [:logger],
     registered: [AF.Server],
     mod: {ActionFolders, []}
    ]
  end

  def run(_) do

  end

  defp deps do

  end

end
