require "test/unit"
require_relative "helpers.rb"

class Tests < Test::Unit::TestCase

  def setup
    $source_dir = TestHelper::GetTestDirectory()
    $backup_dir = TestHelper::GetTestDirectory()
    puts "Source: #{$source_dir}"
    puts "Backup: #{$backup_dir}"
  end

  def teardown
    TestHelper::DeleteTestDirectory($source_dir)
    TestHelper::DeleteTestDirectory($backup_dir)
  end

  def assertResultsAsExpected(expected, actual)
    expected.each do |key, value|
     assert_equal(value, actual[key])
    end
  end

  # TODO
  # - Permissions
  # - Ignore dir option
  #
  # - Refactor this so it's less repetitive.

  def test_file_size_differs
    TestHelper::FillContents($source_dir, {
      'A.txt' => {
        type: 'file',
        contents: 'AA',
      }
    })
    TestHelper::FillContents($backup_dir, {
      'A.txt' => {
        type: 'file',
        contents: 'AAA',
      }
    })
    expected_results = {
      items_processed: 2,
      similarities: 1,
      differences: 1,
      skipped: 0,
      errors: 0,
    }
    actual_results = TestHelper::RunVerification(
        [$source_dir, $backup_dir]
    )
    assertResultsAsExpected(expected_results, actual_results)
  end

  def test_file_contents_different_no_sample
    TestHelper::FillContents($source_dir, {
      'A.txt' => {
        type: 'file',
        contents: 'BBB',
      }
    })
    TestHelper::FillContents($backup_dir, {
      'A.txt' => {
        type: 'file',
        contents: 'AAA',
      }
    })
    expected_results = {
      items_processed: 2,
      similarities: 2,
      differences: 0,
      skipped: 0,
      errors: 0,
    }
    actual_results = TestHelper::RunVerification(
        [$source_dir, $backup_dir]
    )
    assertResultsAsExpected(expected_results, actual_results)
  end

  def test_file_contents_different_with_sample
    TestHelper::FillContents($source_dir, {
      'A.txt' => {
        type: 'file',
        contents: 'BBB',
      }
    })
    TestHelper::FillContents($backup_dir, {
      'A.txt' => {
        type: 'file',
        contents: 'AAA',
      }
    })
    expected_results = {
      items_processed: 2,
      similarities: 1,
      differences: 1,
      skipped: 0,
      errors: 0,
    }
    actual_results = TestHelper::RunVerification(
        [$source_dir, $backup_dir, "-s", "1"]
    )
    assertResultsAsExpected(expected_results, actual_results)
  end

  def test_missing_directory_no_count
    TestHelper::FillContents($source_dir, {
      'A.txt' => {
        type: 'file',
        contents: 'AAA',
      },
      'missingdir' => {
        type: 'directory',
        contents: {
          'Z.txt' => {
            type: 'file',
            contents: 'ABC'
          }
        }
      }
    })
    TestHelper::FillContents($backup_dir, {
      'A.txt' => {
        type: 'file',
        contents: 'AAA',
      }
    })
    expected_results = {
      items_processed: 3,
      similarities: 2,
      differences: 1,
      skipped: 0,
      errors: 0,
    }
    actual_results = TestHelper::RunVerification(
        [$source_dir, $backup_dir]
    )
    assertResultsAsExpected(expected_results, actual_results)
  end

  def test_missing_directory_with_count
    TestHelper::FillContents($source_dir, {
      'A.txt' => {
        type: 'file',
        contents: 'AAA',
      },
      'missingdir' => {
        type: 'directory',
        contents: {
          'Z.txt' => {
            type: 'file',
            contents: 'ABC'
          }
        }
      }
    })
    TestHelper::FillContents($backup_dir, {
      'A.txt' => {
        type: 'file',
        contents: 'AAA',
      }
    })
    expected_results = {
      items_processed: 4,
      similarities: 2,
      differences: 2,
      skipped: 0,
      errors: 0,
    }
    actual_results = TestHelper::RunVerification(
        [$source_dir, $backup_dir, "-c"]
    )
    assertResultsAsExpected(expected_results, actual_results)
  end

  def test_missing_directory_ignored
    TestHelper::FillContents($source_dir, {
      'A.txt' => {
        type: 'file',
        contents: 'AAA',
      },
      'missingdir_ignored' => {
        type: 'directory',
        contents: {
          'Z.txt' => {
            type: 'file',
            contents: 'ABC'
          }
        }
      }
    })
    TestHelper::FillContents($backup_dir, {
      'A.txt' => {
        type: 'file',
        contents: 'AAA',
      }
    })
    # FIXME: Is this the beavhior we actually want? The ignored directory is
    # counted as both processed and skipped.
    expected_results = {
      items_processed: 3,
      similarities: 3,
      differences: 0,
      skipped: 1,
      errors: 0,
    }
    ignored_path = File.join($source_dir, "missingdir_ignored")
    actual_results = TestHelper::RunVerification(
        [$source_dir, $backup_dir, "-c", "-i", ignored_path]
    )
    assertResultsAsExpected(expected_results, actual_results)
  end

end
