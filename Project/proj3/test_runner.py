#!/usr/bin/env python3

import argparse
import os
import os.path
import tempfile
import subprocess
import signal
import re
import sys

script_dir = os.path.realpath(sys.path[0])
logisim_location = os.path.join(script_dir, "logisim-evolution.jar")

class LogisimTest():
  """
  Runs a circuit file and compares output against the provided reference file.
  """

  def __init__(self, group_path, circ_path, trace_path):
    self.group_path  = group_path
    self.circ_path  = circ_path
    self.trace_path = trace_path

  def __call__(self, filename):
    output = tempfile.TemporaryFile(mode="r+")
    try:
      stdinf = open("/dev/null")
    except Exception as e:
      try:
        stdinf = open("nul")
      except Exception as e:
         print("Could not open nul or /dev/null. Program will most likely error now.")
    proc = subprocess.Popen(["java", "-jar", logisim_location, "-tty", "table", self.circ_path],
                            cwd=self.group_path, stdin=stdinf, stdout=subprocess.PIPE)
    try:
      reference = open(self.trace_path)
      passed = compare_unbounded(proc.stdout, reference, filename)
    finally:
      try:
        os.kill(proc.pid, signal.SIGTERM)
      except Exception as e:
        pass
    if passed:
      return (True, "Matched expected output")
    else:
      return (False, "Did not match expected output")

def compare_unbounded(student_out, reference_out, filename):
  passed = True
  student_output_array = []
  while True:
    line1 = student_out.readline().rstrip().decode("utf-8", "namereplace")
    while is_logisim_header(line1):
      line1 = student_out.readline().rstrip().decode("utf-8", "namereplace")
    line2 = reference_out.readline().rstrip()
    if line2 == "":
      break
    student_output_array.append(line1)
    normalized_line1 = normalize_table_line(line1)
    normalized_line2 = normalize_table_line(line2)
    m = re.match(normalized_line2, normalized_line1)
    if m == None or m.start() != 0 or m.end() != len(normalized_line2):
      passed = False
  with open(filename, "w") as student_output:
    for line in student_output_array:
      student_output.write(line + "\n")
  return passed

def is_logisim_header(line):
  stripped = line.strip()
  if stripped.startswith("Test"):
    return True
  fields = stripped.split()
  if not fields:
    return False
  # Newer Logisim versions print a table header containing pin names before
  # the data rows. Data rows start with either hex values or binary digits.
  return not re.match(r"^(0x[0-9a-fA-F]+|[01xX]+)$", fields[0])

def normalize_table_line(line):
  fields = line.strip().split()
  if not fields:
    return line

  # Newer Logisim prints table values in hex for buses and binary for small pins.
  if fields[0].startswith("0x"):
    widths_by_count = {
      5: [8, 32, 4, 32, 32],
      11: [32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 16],
      16: [8, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 5, 5, 5, 1, 32],
    }
    widths = widths_by_count.get(len(fields))
    if widths is None:
      return line
    try:
      return "\t".join(format_table_field(field, width) for field, width in zip(fields, widths))
    except ValueError:
      return line

  # Reference files use tab-separated fields, with spaces inside binary groups.
  tab_fields = line.strip().split("\t")
  if len(tab_fields) > 1:
    normalized_fields = [re.sub(r"\s+", "", field) for field in tab_fields]
    if all(re.match(r"^[01]+$", field) for field in normalized_fields):
      return "\t".join(normalized_fields)

  return line

def format_table_field(field, width):
  if field.startswith("0x"):
    value = int(field, 16)
  else:
    value = int(field, 2)
  return format(value & ((1 << width) - 1), "0%db" % width)

def run_test(group_path, test_slug, output_type=None):
  output_slug = test_slug
  if output_type:
    output_slug += "-" + output_type
  circ_path = os.path.join(group_path, "%s.circ" % test_slug)
  reference_output_path = os.path.join(group_path, "reference_output/%s-ref.out" % output_slug)
  student_output_path = os.path.join(group_path, "student_output/%s-student.out" % output_slug)
  test_runner = LogisimTest(group_path, circ_path, reference_output_path)
  return test_runner(student_output_path)

class TestPart:
  def __init__(self, part, group, tests):
    self.part = part
    self.group = group
    self.tests = tests
  
  def get(self):
    return (self.part, self.group, self.tests)

def run_tests(mpart, mgroup, test):
  test_parts = []
  parts = sorted([folder for folder in os.listdir(os.path.join(script_dir, "tests")) if os.path.isdir(os.path.join(script_dir, "tests", folder))]) if mpart is None else [mpart]
  for part in parts:
    part_path = os.path.join(script_dir, "tests", part)
    groups = [mgroup] if mgroup is not None else sorted([folder for folder in os.listdir(part_path) if os.path.isdir(os.path.join(part_path, folder))])
    for group in groups:
      tests = []
      group_path = "%s/%s" % (part_path, group)
      if not os.path.isdir(group_path):
        groups = [filename for filename in os.listdir(part_path) if not filename.startswith(".")]
        raise ValueError("Invalid test group: %s (choose from %s)" % (group, ", ".join(groups)))

      fls = []
      if test is None:
        fls = os.listdir(group_path)
      else:
        f = os.path.join(group_path, test)
        if not os.path.isfile(f) or not re.match(r"^(.+)\.circ$", test):
          raise ValueError("Invalid test file: %s" % f)
        fls.append(test)

      for filename in sorted(fls):
        match = re.match(r"^(.+)\.circ$", filename)
        if match:
          test_slug = match.group(1)
          tests.append(("%s test" % test_slug, test_slug))

      test_parts.append(TestPart(part, group, tests))
  for part, group, tests in [p.get() for p in test_parts]:
    part_path = os.path.join(script_dir, "tests", part)
    group_path = "%s/%s" % (part_path, group)
    print("Running tests for %s/%s..." % (part, group))
    tests_passed = 0
    tests_failed = 0

    for test in tests:
      description, test_slug = test[:2]
      output_type = (test[2] if len(test) >= 3 else None)
      did_pass, fail_reason = False, "Unknown test error"
      try:
        did_pass, fail_reason = run_test(group_path, test_slug, output_type)
      except Exception as ex:
        print(ex)
      if did_pass:
        print("\tPASSED test: %s" % description)
        tests_passed += 1
      else:
        print("\tFAILED test: %s (%s)" % (description, fail_reason))
        tests_failed += 1
    if len(tests) == 0:
      print("There are no tests for %s/%s!\n" % (part, group))
    else:
      print("Passed %d/%d tests\n" % (tests_passed, (tests_passed + tests_failed)))

if __name__ == "__main__":
  parser = argparse.ArgumentParser(description="Run Logisim tests")
  parts = ["part_a", "part_b"]
  parser.add_argument("part", choices=parts, help="The project part the test is under (a/b)", nargs="?", default=None)
  parser.add_argument("group", help="The group of tests to run. If left blank, it will run all the tests of the part", default=None, nargs="?")
  parser.add_argument("test", help="A specific test file to run. You must specify the correct group and the full filename! If left blank, it will be ignored", nargs="?")
  args = parser.parse_args()
  
  run_tests(args.part, args.group, args.test)
