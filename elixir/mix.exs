defmodule SuperstateApiKeyRequest.MixProject do
  use Mix.Project

  def project do
    [
      app: :superstate_api_key_request,
      version: "0.1.4",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      name: "SuperstateApiKeyRequest",
      source_url: "https://github.com/superstateinc/superstate-api-key-request-elixir",
      docs: [
        main: "SuperstateApiKeyRequest",
        extras: ["README.md"]
      ]
    ]
  end

  def application do
    [
      extra_applications: [:logger, :crypto]
    ]
  end

  defp deps do
    [
      {:jason, "~> 1.4"},
      {:httpoison, "~> 2.0"},
      {:ex_doc, "~> 0.27", only: :dev, runtime: false}
    ]
  end

  defp description() do
    "Make an API request to a Superstate endpoint that requires an API key"
  end

  defp package() do
    [
      licenses: ["ISC"],
      links: %{"GitHub" => "https://github.com/superstateinc/superstate-api-key-request-elixir"},
      maintainers: ["Superstate"],
      files: ~w(lib .formatter.exs mix.exs README.md LICENSE CHANGELOG.md)
    ]
  end
end