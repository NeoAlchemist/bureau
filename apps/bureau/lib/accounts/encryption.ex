defmodule Bureau.Account.Encryption do
  alias Comeonin.Bcrypt

  def hash(pass), do: Bcrypt.hashpwsalt(pass)
  def validate(pass, hash), do: Bcrypt.checkpw(pass, hash)
end
