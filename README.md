This package exists to house Ubuntu's settings for the Calamares installer.

If you want to add a new package for your flavor, here's how to do it:
 1. Create a new top-level directory (like Lubuntu's, you could just copy
    theirs and customize).
 2. Edit files and rename the branding directory for your flavor. All of the
    configuration files are pretty self-explanatory, but they're documented
    well upstream, so it shouldn't be hard to put your own spin on things.
 3. Create a new binary package, and *make sure to Provides+Conflicts against
    `calamares-settings-ubuntu-flavor`*. This needs to be done because all
    subdirectories are installed in the same location, so this makes sure that
    nobody tries to install any two binary packages at the same time.

That's about it. If you have any questions, feel free to email Simon Quigley
at tsimonq2@ubuntu.com or consult the upstream documentation.

## CI / release (KzhenTo fork)

- Pull requests and pushes to `main`, `kzhento`, or `action/**` run
  `.github/workflows/ci.yml`: static gate -> Debian package build (with lintian
  error checks) -> install smoke test.
- Pushing a `v*` / `kzhento/*` tag, or manually triggering the workflow in
  Actions (a tag is required), runs `.github/workflows/release.yml`. Artifacts
  include `.deb`, `.changes`, `.buildinfo`, and `SHA256SUMS`. Releases are
  **created as drafts by default**; publish them only after review.
- The gate and smoke scripts are `.github/scripts/ci-gate.sh` and
  `.github/scripts/smoke-test.sh`; both can be reproduced locally on Ubuntu 26.04.
