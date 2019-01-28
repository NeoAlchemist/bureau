defmodule Bureau.AccountTest do
  use Bureau.DataCase

  alias Bureau.Account
  alias Bureau.User

  @good_attrs %{username: "Marko", email: "marko@gmail.com", password: "12345Ree"}
  @bad_attrs %{username: "Marko", email: "marko@gmail.com", password: "213231231"}
  @update_pass %{password: "12345Ree", new_password: "12345Tee"}

  test "create with error user" do
    assert {:error, _} = Account.create(%User{}, @bad_attrs)
  end

  test "create and update and delete user" do
    assert {:ok, schema} = Account.create(%User{}, @good_attrs)
    assert {:ok, updated} = Account.update(schema, @update_pass)
    assert {:ok, deleted} = Account.delete(updated)
  end

  test "return error if user already exist" do
    Account.create(%User{}, @good_attrs)
    assert {:error, _} = Account.create(%User{}, @good_attrs)
  end
end
