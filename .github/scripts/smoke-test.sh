#!/usr/bin/env bash
# Post-install smoke test. Run inside an Ubuntu 26.04 container AFTER installing
# calamares-settings-ubuntu-common(-data) and calamares-settings-kubuntu .debs.
# Requires: dpkg, desktop-file-utils, file, python3 + python3-yaml.

set -uo pipefail

FAILURES=0
section() { printf '\n== %s ==\n' "$*"; }
ok()      { printf '  OK   %s\n' "$*"; }
bad()     { printf '  FAIL %s\n' "$*" >&2; FAILURES=$((FAILURES + 1)); }

section "Installed packages"
for pkg in calamares-settings-ubuntu-common \
           calamares-settings-ubuntu-common-data \
           calamares-settings-kubuntu; do
    status=$(dpkg-query -W -f='${db:Status-Abbrev}' "$pkg" 2>/dev/null || true)
    [[ "$status" == ii* ]] && ok "$pkg installed" || bad "$pkg not installed correctly (status: '${status}')"
done

section "Key installed paths"
REQUIRED_FILES=(
    /usr/bin/calamares-launch-normal
    /usr/bin/calamares-logs-helper
    /usr/bin/calamares-launch-oem
    /usr/bin/snap-seed-glue-emb
    /usr/libexec/calamares-oemprep.sh
    /usr/libexec/fixconkeys-part1
    /usr/libexec/fixconkeys-part2
    /usr/share/applications/kubuntu-calamares.desktop
    /usr/share/applications/calamares-launch-oem.desktop
    /etc/calamares/settings.conf
    /etc/calamares/modules/automirror.conf
    /etc/calamares/modules/partition.conf
    /etc/calamares/branding/kzhento/branding.desc
    /etc/calamares/branding/kzhento/logo.png
    /etc/calamares/branding/kzhento/welcome.png
    /etc/calamares/branding/kzhento/show.qml
    /etc/calamares/oemconfig.tar.gz
)
MISSING=0
for file in "${REQUIRED_FILES[@]}"; do
    if [[ ! -e "$file" ]]; then
        bad "missing: $file"
        MISSING=$((MISSING + 1))
    fi
done
(( MISSING == 0 )) && ok "${#REQUIRED_FILES[@]} key files present"

# automirror and pkgselect live under multiarch paths; debian/*.links provides compatibility links.
AUTOMIRROR_OK=0
for file in /usr/lib/calamares/modules/automirror/main.py \
            /usr/lib/*/calamares/modules/automirror/main.py; do
    if [[ -f "$file" ]]; then AUTOMIRROR_OK=1; break; fi
done
(( AUTOMIRROR_OK == 1 )) && ok "automirror module present" || bad "automirror main.py not found"

PKGSELECT_OK=0
for file in /usr/lib/*/calamares/modules/pkgselect/libcalamares_viewmodule_pkgselect.so; do
    if [[ -f "$file" ]]; then PKGSELECT_OK=1; break; fi
done
(( PKGSELECT_OK == 1 )) && ok "pkgselect module present" || bad "pkgselect .so not found"

section "Desktop entries"
for file in /usr/share/applications/kubuntu-calamares.desktop \
            /usr/share/applications/calamares-launch-oem.desktop; do
    [[ -f "$file" ]] || continue
    desktop-file-validate "$file" || bad "desktop-file-validate failed: $file"
done
ok "desktop entry validation complete"

section "Installed config parsing"
mapfile -t CFG_FILES < <(find /etc/calamares -type f \
    \( -name '*.conf' -o -name '*.conf.oem' -o -name 'branding.desc' \) -print | sort)
if ! python3 - "${CFG_FILES[@]}" <<'PY'
import sys
import yaml

failed = False
for name in sys.argv[1:]:
    with open(name, encoding="utf-8") as handle:
        text = handle.read()
    significant = "\n".join(
        line for line in text.splitlines()
        if line.strip() and not line.lstrip().startswith("#")
    )
    if significant.startswith("["):
        continue  # INI-style config
    try:
        yaml.safe_load(text.replace("\t", "    "))
    except Exception as exc:  # noqa: BLE001
        print(f"  FAIL installed config {name}: {exc}", file=sys.stderr)
        failed = True
sys.exit(1 if failed else 0)
PY
then
    FAILURES=$((FAILURES + 1))
else
    ok "parsed ${#CFG_FILES[@]} installed configs"
fi

AUTOMIRROR_PY=""
for file in /usr/lib/calamares/modules/automirror/main.py \
            /usr/lib/*/calamares/modules/automirror/main.py; do
    if [[ -f "$file" ]]; then AUTOMIRROR_PY=$file; break; fi
done
if [[ -n "$AUTOMIRROR_PY" ]]; then
    if python3 - "$AUTOMIRROR_PY" <<'PY'
import ast
import sys

with open(sys.argv[1], encoding="utf-8") as handle:
    ast.parse(handle.read(), filename=sys.argv[1])
PY
    then
        ok "automirror/main.py syntax OK"
    else
        bad "automirror/main.py syntax error"
    fi
fi

section "OEM configuration archive"
OEM_TMP=$(mktemp -d)
trap 'rm -rf "$OEM_TMP"' EXIT
# Mirror calamares-oemprep.sh: archive root is kzhento/oemconfig/, strip two levels.
if tar -xzf /etc/calamares/oemconfig.tar.gz -C "$OEM_TMP" --strip-components=2; then
    OEM_FILES=(
        usr/bin/calamares-finish-oem
        usr/bin/basicwallpaper
        usr/libexec/calamares-oemfinish.sh
        usr/libexec/start-kubuntu-oem-env
        usr/share/wayland-sessions/kubuntu-oem-environment.desktop
        usr/share/applications/calamares-finish-oem.desktop
        etc/calamares/settings.conf
        etc/calamares/modules/welcome.conf
        etc/sudoers.oem
        home/oem/Desktop/calamares-finish-oem.desktop
    )
    OEM_BAD=0
    for file in "${OEM_FILES[@]}"; do
        [[ -e "$OEM_TMP/$file" ]] || { bad "OEM archive missing: $file"; OEM_BAD=$((OEM_BAD + 1)); }
    done
    (( OEM_BAD == 0 )) && ok "OEM archive structure OK (${#OEM_FILES[@]} entries)"

    sudoers_mode=$(stat -c '%a' "$OEM_TMP/etc/sudoers.oem" 2>/dev/null || true)
    [[ "$sudoers_mode" == 400 ]] && ok "sudoers.oem mode is 400" \
        || bad "sudoers.oem wrong mode: '$sudoers_mode' (expected 400)"

    sudoers_owner=$(stat -c '%u:%g' "$OEM_TMP/etc/sudoers.oem" 2>/dev/null || true)
    [[ "$sudoers_owner" == 0:0 ]] && ok "sudoers.oem owned by root:root" \
        || bad "sudoers.oem wrong owner: '$sudoers_owner'"
else
    bad "cannot extract /etc/calamares/oemconfig.tar.gz"
fi

section "Package integrity"
for pkg in calamares-settings-ubuntu-common calamares-settings-ubuntu-common-data calamares-settings-kubuntu; do
    if changes=$(dpkg -V "$pkg" 2>&1) && [[ -z "$changes" ]]; then
        ok "$pkg file verification passed"
    else
        bad "$pkg file verification failed: ${changes:-dpkg -V failed}"
    fi
done

printf '\n'
if (( FAILURES > 0 )); then
    printf 'smoke test failed: %d issue(s)\n' "$FAILURES" >&2
    exit 1
fi
printf 'smoke test passed\n'
