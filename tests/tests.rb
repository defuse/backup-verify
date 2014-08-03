require "test/unit"
require_relative "helpers.rb"

class Tests < Test::Unit::TestCase

  def setup
    $source_dir = TestHelper::GetTestDirectory()
    $backup_dir = TestHelper::GetTestDirectory()
  end

  def teardown
    TestHelper::DeleteTestDirectory($source_dir)
    TestHelper::DeleteTestDirectory($backup_dir)
  end

  # TODO
  # - Permissions
  # - Ignore dir option
  #
  # - Refactor this so it's less repetitive.

  def test_file_size_differs
    source_contents = {
      'A.txt' => {
        type: 'file',
        contents: 'AA',
      }
    }
    backup_contents = {
      'A.txt' => {
        type: 'file',
        contents: 'AAA',
      }
    }
    TestHelper::FillContents($source_dir, source_contents)
    TestHelper::FillContents($backup_dir, backup_contents)
    results = TestHelper::RunVerification(
        [$source_dir, $backup_dir]
    )
    assert_equal(2, results[:items_processed])
    assert_equal(1, results[:similarities])
    assert_equal(1, results[:differences])
    assert_equal(0, results[:skipped])
    assert_equal(0, results[:errors])
  end

  def test_file_contents_differs_no_sample
    source_contents = {
      'A.txt' => {
        type: 'file',
        contents: 'AAA',
      }
    }
    backup_contents = {
      'A.txt' => {
        type: 'file',
        contents: 'BBB',
      }
    }
    TestHelper::FillContents($source_dir, source_contents)
    TestHelper::FillContents($backup_dir, backup_contents)
    results = TestHelper::RunVerification(
        [$source_dir, $backup_dir]
    )
    assert_equal(2, results[:items_processed])
    assert_equal(2, results[:similarities])
    assert_equal(0, results[:differences])
    assert_equal(0, results[:skipped])
    assert_equal(0, results[:errors])
  end

  def test_file_contents_differs_with_sample
    source_contents = {
      'A.txt' => {
        type: 'file',
        contents: 'AAA',
      }
    }
    backup_contents = {
      'A.txt' => {
        type: 'file',
        contents: 'BBB',
      }
    }
    TestHelper::FillContents($source_dir, source_contents)
    TestHelper::FillContents($backup_dir, backup_contents)
    results = TestHelper::RunVerification(
        [$source_dir, $backup_dir, "-s", "1"]
    )
    assert_equal(2, results[:items_processed])
    assert_equal(1, results[:similarities])
    assert_equal(1, results[:differences])
    assert_equal(0, results[:skipped])
    assert_equal(0, results[:errors])
  end

end
