#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "${repo_root}"

target="${1:-}"
case "${target}" in
  fn-sync|haima-cloud|moonlight-vplus|qiyou|scriptplayerplus|tmog|xenolauncher) ;;
  *)
    echo "Usage: $0 {fn-sync|haima-cloud|moonlight-vplus|qiyou|scriptplayerplus|tmog|xenolauncher}" >&2
    exit 2
    ;;
esac

update_cask() {
  local token="$1"
  local version="$2"
  local sha256="$3"
  local file="Casks/${token}.rb"
  local current_version current_sha256

  if [[ ! "${sha256}" =~ ^[0-9a-f]{64}$ ]]
  then
    echo "Invalid SHA-256 for ${token}: ${sha256}" >&2
    exit 1
  fi

  current_version="$(sed -n 's/^  version "\(.*\)"$/\1/p' "${file}")"
  current_sha256="$(sed -n 's/^  sha256 "\(.*\)"$/\1/p' "${file}")"
  if [[ "${current_version}" == "${version}" && "${current_sha256}" == "${sha256}" ]]
  then
    echo "${token} is current at ${version}."
    return
  fi

  TOKEN="${token}" VERSION="${version}" SHA256="${sha256}" ruby -pi -e '
    gsub(/^  version ".*"$/, %(  version "#{ENV.fetch("VERSION")}"))
    gsub(/^  sha256 ".*"$/, %(  sha256 "#{ENV.fetch("SHA256")}"))
  ' "${file}"
  echo "Updated ${token}: ${current_version} -> ${version}"
}

sync_github_cask() {
  local token="$1"
  local upstream="$2"
  local tag_prefix="$3"
  local asset_template="$4"
  local release_json tag version asset_name asset_url digest sha256

  release_json="$(gh api "repos/${upstream}/releases/latest")"
  tag="$(jq -r '.tag_name' <<<"${release_json}")"
  version="${tag#"${tag_prefix}"}"
  asset_name="${asset_template//\{version\}/${version}}"
  asset_url="$(jq -r --arg name "${asset_name}" '.assets[] | select(.name == $name) | .browser_download_url' <<<"${release_json}")"
  digest="$(jq -r --arg name "${asset_name}" '.assets[] | select(.name == $name) | .digest // empty' <<<"${release_json}")"

  if [[ -z "${asset_url}" ]]
  then
    echo "Missing ${upstream} release asset: ${asset_name}" >&2
    exit 1
  fi

  if [[ "${digest}" == sha256:* ]]
  then
    sha256="${digest#sha256:}"
  else
    sha256="$(curl -fsSL "${asset_url}" | sha256sum | cut -d ' ' -f 1)"
  fi

  update_cask "${token}" "${version}" "${sha256}"
}

case "${target}" in
  moonlight-vplus)
    sync_github_cask "moonlight-vplus" "qiin2333/moonlight-qt" "v" "Moonlight-VPlus-{version}-arm64.dmg"
    ;;
  scriptplayerplus)
    sync_github_cask "scriptplayerplus" "sioaeko/scriptplayer-plus" "v" "ScriptPlayerPlus-{version}-arm64-mac.dmg"
    ;;
  xenolauncher)
    sync_github_cask "xenolauncher" "m5kro/Xenolauncher" "" "Xenolauncher-arm64.zip"
    ;;
esac

if [[ "${target}" == "tmog" ]]
then
  tmog_json="$(curl -fsSL https://www.tmog.org/downloads/release.json)"
  tmog_version="$(jq -r '"\(.version),\(.build)"' <<<"${tmog_json}")"
  tmog_sha256="$(jq -r '.sha256' <<<"${tmog_json}")"
  update_cask "tmog" "${tmog_version}" "${tmog_sha256}"
fi

if [[ "${target}" == "haima-cloud" ]]
then
  haima_json="$(curl -fsSL https://pc-rel.haimawan.com/cloud/app/version/latest \
    -H 'Content-Type: application/json' \
    -d '{"channelCode":"haimayun","clientType":"MAC","platform":"mac_arm"}')"
  haima_version="$(jq -r '.result.versionName // empty' <<<"${haima_json}")"
  haima_url="$(jq -r '.result.pkgUrl // empty' <<<"${haima_json}")"
  current_haima_version="$(sed -n 's/^  version "\(.*\)"$/\1/p' Casks/haima-cloud.rb)"

  if [[ -z "${haima_version}" || -z "${haima_url}" ]]
  then
    echo "Haima release API did not return an arm64 macOS release." >&2
    exit 1
  fi

  if [[ "${current_haima_version}" == "${haima_version}" ]]
  then
    echo "haima-cloud is current at ${haima_version}."
  else
    haima_sha256="$(curl -fsSL "${haima_url}" | sha256sum | cut -d ' ' -f 1)"
    update_cask "haima-cloud" "${haima_version}" "${haima_sha256}"
  fi
fi

if [[ "${target}" == "fn-sync" ]]
then
  fn_sync_page="$(curl -fsSL 'https://fnnas.com/download?key=fn-sync-client')"
  fn_sync_version="$(sed -n 's/.*fn-sync_\([0-9][0-9.]*\)_aarch64\.dmg.*/\1/p' <<<"${fn_sync_page}" | head -n 1)"

  if [[ -z "${fn_sync_version}" ]]
  then
    echo "Unable to determine the latest Feiniu Sync version." >&2
    exit 1
  fi

  fn_sync_url="https://iso.liveupdate.fnnas.com/pc/fn-sync_${fn_sync_version}_aarch64.dmg"
  fn_sync_payload="$(jq -cn --arg url "${fn_sync_url}" '{url: $url}')"
  fn_sync_signed_url="$(curl -fsSL 'https://fnnas.com/asset/download-sign' \
    -H 'Content-Type: application/json' \
    --data "${fn_sync_payload}" | jq -r '.url // empty')"

  if [[ -z "${fn_sync_signed_url}" ]]
  then
    echo "Unable to obtain a signed Feiniu Sync download URL." >&2
    exit 1
  fi

  fn_sync_sha256="$(curl -fsSL "${fn_sync_signed_url}" | sha256sum | cut -d ' ' -f 1)"
  update_cask "fn-sync" "${fn_sync_version}" "${fn_sync_sha256}"
fi

if [[ "${target}" == "qiyou" ]]
then
  qiyou_json="$(curl -fsSL 'https://apifast.qiyou.cn/api/common_bll/v1/official_web/download_url?client_type=MAC')"
  qiyou_url="$(jq -r '.download_url // empty' <<<"${qiyou_json}")"
  qiyou_raw_version="$(sed -n 's/.*vrelease-\([0-9][0-9.]*\)-Release.*/\1/p' <<<"${qiyou_url}")"

  if [[ "${qiyou_raw_version}" =~ ^([0-9]+)\.([0-9]+)\.([0-9]+)$ ]]
  then
    qiyou_version="${BASH_REMATCH[1]}.${BASH_REMATCH[2]}.${BASH_REMATCH[3]}"
  elif [[ "${qiyou_raw_version}" =~ ^([0-9])([0-9])([0-9]+)$ ]]
  then
    qiyou_version="${BASH_REMATCH[1]}.${BASH_REMATCH[2]}.${BASH_REMATCH[3]}"
  else
    echo "Unable to determine the latest Qiyou version from: ${qiyou_url}" >&2
    exit 1
  fi

  if [[ -z "${qiyou_version}" ]]
  then
    echo "Unable to determine the latest Qiyou version from: ${qiyou_url}" >&2
    exit 1
  fi

  qiyou_version_template='vrelease-#{version.major}#{version.minor}#{version.patch}'
  qiyou_url_template="${qiyou_url/vrelease-${qiyou_raw_version}/${qiyou_version_template}}"
  current_qiyou_version="$(sed -n 's/^  version "\(.*\)"$/\1/p' Casks/qiyou.rb)"
  current_qiyou_url="$(sed -n 's/^  url "\(.*\)",$/\1/p' Casks/qiyou.rb)"

  if [[ "${current_qiyou_version}" == "${qiyou_version}" && "${current_qiyou_url}" == "${qiyou_url_template}" ]]
  then
    echo "qiyou is current at ${qiyou_version}."
  else
    qiyou_sha256="$(curl -fsSL "${qiyou_url}" | sha256sum | cut -d ' ' -f 1)"
    update_cask "qiyou" "${qiyou_version}" "${qiyou_sha256}"
    QIYOU_URL="${qiyou_url_template}" ruby -pi -e '
      gsub(/^  url ".*",$/, %(  url "#{ENV.fetch("QIYOU_URL")}",))
    ' Casks/qiyou.rb
    echo "Updated qiyou download URL."
  fi
fi
