defmodule MyxqlTest do
  use ExUnit.Case, async: true
  import Myxql.Messages

  test "myxql" do
    opts = [
      host: "127.0.0.1",
      port: 8006,
      user: "root",
      password: "secret",
      database: "myxql_test",
      timeout: 5000
    ]

    {:ok, conn} = Myxql.Protocol.connect(opts)

    assert resultset(column_definitions: [{"2*3", _}, {"4*5", _}], rows: [[6, 20]]) =
             Myxql.Protocol.query(conn, "SELECT 2*3, 4*5")

    assert ok_packet() =
             Myxql.Protocol.query(conn, "CREATE TABLE IF NOT EXISTS integers (x int)")

    assert ok_packet() = Myxql.Protocol.query(conn, "TRUNCATE TABLE integers")
    assert ok_packet() = Myxql.Protocol.query(conn, "INSERT INTO integers VALUES (10)")
    assert ok_packet() = Myxql.Protocol.query(conn, "INSERT INTO integers VALUES (20)")

    assert resultset(column_definitions: [{"x", _}], rows: [[10], [20]]) =
             Myxql.Protocol.query(conn, "SELECT * FROM integers")

    assert err_packet(error_message: "You have an error in your SQL syntax" <> _) =
             Myxql.Protocol.query(conn, "bad")
  end
end