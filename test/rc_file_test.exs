defmodule RcFileTest do
  use PowerAssert

  setup do
    TestHelper.cleanup
    on_exit fn -> TestHelper.cleanup end
  end

  test "that rc file is created when it doesn't exist" do
    assert !File.exists?(TestHelper.path)
    TestHelperTask.run(["initrc"])
    assert File.exists?(TestHelper.path)
  end

  test "that rc file contains expected values" do
    TestHelperTask.run(["initrc"])

    content = File.read! TestHelper.path
    assert String.contains?(content, "a: A")
    assert String.contains?(content, "b: false")
    assert String.contains?(content, "c: 1")
    assert String.contains?(content, "d: 2.3")
  end

  test "rc file is loaded back with the correct types" do
    TestHelperTask.run(["initrc"])

    loaded = Ra.RcFile.load(TestHelperTask)
    assert "A"   == loaded.a
    assert false == loaded.b
    assert 1     == loaded.c
    assert 2.3   == loaded.d
  end

  test "rc file is passed into function" do
    TestHelperTask.run(["initrc"])
    rc = TestHelperTask.run(["print"])

    assert "A"   == rc.a
    assert false == rc.b
    assert 1     == rc.c
    assert 2.3   == rc.d
  end
end
