defmodule JsonSchemaTestSuite.Draft7.AllOfTest do
  use ExUnit.Case

  import Xema, only: [valid?: 2]

  describe "allOf" do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{
              "allOf" => [
                %{"properties" => %{"bar" => %{"type" => "integer"}}, "required" => ["bar"]},
                %{"properties" => %{"foo" => %{"type" => "string"}}, "required" => ["foo"]}
              ]
            },
            draft: "draft7"
          )
      }
    end

    test "allOf", %{schema: schema} do
      assert valid?(schema, %{"bar" => 2, "foo" => "baz"})
    end

    test "mismatch second", %{schema: schema} do
      refute valid?(schema, %{"foo" => "baz"})
    end

    test "mismatch first", %{schema: schema} do
      refute valid?(schema, %{"bar" => 2})
    end

    test "wrong type", %{schema: schema} do
      refute valid?(schema, %{"bar" => "quux", "foo" => "baz"})
    end
  end

  describe "allOf with base schema" do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{
              "allOf" => [
                %{"properties" => %{"foo" => %{"type" => "string"}}, "required" => ["foo"]},
                %{"properties" => %{"baz" => %{"type" => "null"}}, "required" => ["baz"]}
              ],
              "properties" => %{"bar" => %{"type" => "integer"}},
              "required" => ["bar"]
            },
            draft: "draft7"
          )
      }
    end

    test "valid", %{schema: schema} do
      assert valid?(schema, %{"bar" => 2, "baz" => nil, "foo" => "quux"})
    end

    test "mismatch base schema", %{schema: schema} do
      refute valid?(schema, %{"baz" => nil, "foo" => "quux"})
    end

    test "mismatch first allOf", %{schema: schema} do
      refute valid?(schema, %{"bar" => 2, "baz" => nil})
    end

    test "mismatch second allOf", %{schema: schema} do
      refute valid?(schema, %{"bar" => 2, "foo" => "quux"})
    end

    test "mismatch both", %{schema: schema} do
      refute valid?(schema, %{"bar" => 2})
    end
  end

  describe "allOf simple types" do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"allOf" => [%{"maximum" => 30}, %{"minimum" => 20}]},
            draft: "draft7"
          )
      }
    end

    test "valid", %{schema: schema} do
      assert valid?(schema, 25)
    end

    test "mismatch one", %{schema: schema} do
      refute valid?(schema, 35)
    end
  end

  describe "allOf with boolean schemas, all true" do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"allOf" => [true, true]},
            draft: "draft7"
          )
      }
    end

    test "any value is valid", %{schema: schema} do
      assert valid?(schema, "foo")
    end
  end

  describe "allOf with boolean schemas, some false" do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"allOf" => [true, false]},
            draft: "draft7"
          )
      }
    end

    test "any value is invalid", %{schema: schema} do
      refute valid?(schema, "foo")
    end
  end

  describe "allOf with boolean schemas, all false" do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"allOf" => [false, false]},
            draft: "draft7"
          )
      }
    end

    test "any value is invalid", %{schema: schema} do
      refute valid?(schema, "foo")
    end
  end

  describe "allOf with one empty schema" do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"allOf" => [%{}]},
            draft: "draft7"
          )
      }
    end

    test "any data is valid", %{schema: schema} do
      assert valid?(schema, 1)
    end
  end

  describe "allOf with two empty schemas" do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"allOf" => [%{}, %{}]},
            draft: "draft7"
          )
      }
    end

    test "any data is valid", %{schema: schema} do
      assert valid?(schema, 1)
    end
  end

  describe "allOf with the first empty schema" do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"allOf" => [%{}, %{"type" => "number"}]},
            draft: "draft7"
          )
      }
    end

    test "number is valid", %{schema: schema} do
      assert valid?(schema, 1)
    end

    test "string is invalid", %{schema: schema} do
      refute valid?(schema, "foo")
    end
  end

  describe "allOf with the last empty schema" do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"allOf" => [%{"type" => "number"}, %{}]},
            draft: "draft7"
          )
      }
    end

    test "number is valid", %{schema: schema} do
      assert valid?(schema, 1)
    end

    test "string is invalid", %{schema: schema} do
      refute valid?(schema, "foo")
    end
  end
end
