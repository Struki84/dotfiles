set -euo pipefail
version=1.0.0
package=omacalendar-1.0.0-1-x86_64.pkg.tar.zst
release_url="https://github.com/brdweb/omacalendar/releases/download/v${version}"
curl -fLO "${release_url}/${package}"
curl -fLO "${release_url}/SHA256SUMS"
grep " ${package}$" SHA256SUMS | sha256sum --check --strict
gh attestation verify "$package" --repo brdweb/omacalendar   --source-ref "refs/tags/v${version}"   --signer-workflow brdweb/omacalendar/.github/workflows/release.yml
gh attestation verify "$package" --repo brdweb/omacalendar   --source-ref "refs/tags/v${version}"   --signer-workflow brdweb/omacalendar/.github/workflows/release.yml   --predicate-type https://spdx.dev/Document/v2.3
sudo pacman -U "./${package}"
systemctl --user daemon-reload
systemctl --user enable --now omacalendard.socket
systemctl --user try-restart omacalendard.service
xdg-mime default org.omacalendar.OmaCalendar.desktop x-scheme-handler/omacalendar
