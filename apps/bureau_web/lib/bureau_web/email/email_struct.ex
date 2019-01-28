defmodule Email do
  @enforce_keys [:to, :data, :template]
  defstruct subject: "Please confirm your email address!",
            to: nil,
            from: "noreply",
            template: nil,
            data: %{}

  @opaque t() :: %__MODULE__{
            subject: String.t(),
            to: String.t(),
            from: String.t(),
            template: atom,
            data: map
          }
end
