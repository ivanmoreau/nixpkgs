{ lib
, fetchFromGitHub
, buildGoModule
, unixODBC
, icu
, nix-update-script
, testers
, usql
}:

buildGoModule rec {
  pname = "usql";
  version = "0.14.0";

  src = fetchFromGitHub {
    owner = "xo";
    repo = "usql";
    rev = "v${version}";
    hash = "sha256-AYo1sRzsOuyv0p3X8/TmsWdCBq3Gcqo0J6+B2aI7UIo=";
  };

  buildInputs = [ unixODBC icu ];

  vendorHash = "sha256-ro/m9t8vHxyAS+a42/OkaqhrUs0FPGu0Ns9tn5HyKXg=";
  proxyVendor = true;

  # Exclude broken impala & hive driver
  # These drivers break too often and are not used.
  #
  # See https://github.com/xo/usql/pull/347
  #
  excludedPackages = [
    "impala"
    "hive"
  ];

  # These tags and flags are copied from build-release.sh
  tags = [
    "most"
    "sqlite_app_armor"
    "sqlite_fts5"
    "sqlite_introspect"
    "sqlite_json1"
    "sqlite_math_functions"
    "sqlite_stat4"
    "sqlite_userauth"
    "sqlite_vtable"
    "sqlite_icu"
    "no_adodb"
  ];

  ldflags = [
    "-s"
    "-w"
    "-X github.com/xo/usql/text.CommandVersion=${version}"
  ];

  # All the checks currently require docker instances to run the databases.
  doCheck = false;

  passthru = {
    updateScript = nix-update-script { };
    tests.version = testers.testVersion {
      inherit version;
      package = usql;
      command = "usql --version";
    };
  };

  meta = with lib; {
    description = "Universal command-line interface for SQL databases";
    homepage = "https://github.com/xo/usql";
    changelog = "https://github.com/xo/usql/releases/tag/v${version}";
    license = licenses.mit;
    maintainers = with maintainers; [ georgyo anthonyroussel ];
    platforms = with platforms; linux ++ darwin;
  };
}
