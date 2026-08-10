{
  lib,
  python3Packages,
  fetchPypi,
  fetchFromGitHub,
  iproute2,
}:

let
  # cyphal-cynic needs the pydsdl.serialize/deserialize/Error API, which only
  # exists starting with this pre-release;
  pydsdl = python3Packages.pydsdl.overrideAttrs (oldAttrs: rec {
    version = "1.25.0rc1";
    src = fetchFromGitHub {
      owner = "OpenCyphal";
      repo = "pydsdl";
      tag = "${version}";
      hash = "sha256-RmBioOlpums8krK8CXbRiu+BNuh6lnn7K06gsjeYcjQ=";
    };
  });
in
python3Packages.buildPythonApplication rec {
  pname = "cyphal-cynic";
  version = "0.2.0";
  pyproject = true;

  src = fetchPypi {
    pname = "cyphal_cynic";
    inherit version;
    hash = "sha256-9rP+B1ZkP3ShX9FNp5H5JTHM1sQFVlTVXUeP1O8x2kg=";
  };

  build-system = [ python3Packages.setuptools ];

  pythonRelaxDeps = [ "rich" ];

  dependencies = with python3Packages; [
    coloredlogs
    pycyphal2
    pydsdl
    pyserial
    pyyaml
    rich
  ]
  ++ pycyphal2.optional-dependencies.pythoncan
  ++ pycyphal2.optional-dependencies.udp;

  optional-dependencies = {
    test = [ python3Packages.pytest ];
  };

  nativeCheckInputs = [
    python3Packages.pytestCheckHook
    iproute2
  ]
  ++ optional-dependencies.test;

  disabledTests = [
    # Hard-codes /bin/bash, which doesn't exist in the build sandbox.
    "test_help_into_closed_pipe"
    # Needs a working UDP multicast setup, which isn't available in the build sandbox.
    "test_runs_without_coloredlogs"
  ];

  pythonImportsCheck = [ "cynic" ];

  meta = {
    description = "Cyphal Network Investigation Console -- a minimal CLI for inspecting and exercising Cyphal networks";
    homepage = "https://opencyphal.org/";
    changelog = "https://github.com/OpenCyphal-Garage/cynic/releases/tag/${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ bjsowa ];
    mainProgram = "cn";
  };
}
