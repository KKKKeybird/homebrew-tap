"""Run in the user's tap. Pull only complete, published, immutable free releases."""
import hashlib, json, pathlib, re, urllib.request
REPO = 'KKKKeybird/convt'
def fetch(url):
    with urllib.request.urlopen(urllib.request.Request(url, headers={'User-Agent': 'convt-free-tap'}), timeout=180) as response:
        return response.read()
release = json.loads(fetch(f'https://api.github.com/repos/{REPO}/releases/latest'))
tag = release['tag_name']
assert re.fullmatch(r'free-[a-f0-9]{12}-[a-f0-9]{12}', tag), tag
assert not release['draft'] and not release['prerelease']
assets = {a['name']: a['browser_download_url'] for a in release['assets']}
zips = [n for n in assets if re.fullmatch(r'convt-free-[0-9A-Za-z.-]+-arm64.zip', n)]
assert len(zips) == 1, zips
name = zips[0]; version = name[len('convt-free-'):-len('-arm64.zip')]
base = f'https://github.com/{REPO}/releases/download/{tag}/'
assert assets[name] == base+name
assert assets['SHA256SUMS'] == base+'SHA256SUMS'
assert any('-sources.tar.gz.part-' in n for n in assets), 'No corresponding source assets'
digests = {}
for line in fetch(assets['SHA256SUMS']).decode().splitlines():
    digest, path = line.split(None, 1)
    assert re.fullmatch('[a-f0-9]{64}', digest)
    digests[path.removeprefix('./')] = digest
assert hashlib.sha256(fetch(assets[name])).hexdigest() == digests[name], 'Release ZIP digest mismatch'
text = '''cask "convt-free" do
  version "VERSION"
  sha256 "DIGEST"

  url "URL"
  name "convt Free (unofficial source build)"
  desc "Local file converter with Finder Quick Action"
  homepage "https://github.com/KKKKeybird/convt"

  depends_on arch: :arm64
  depends_on macos: ">= :ventura"
  conflicts_with cask: "convt"

  app "convt.app"
  binary "#{appdir}/convt.app/Contents/MacOS/convt", target: "convt-free"
  artifact "convt-free.workflow", target: "#{Dir.home}/Library/Services/convt-free.workflow"

  caveats <<~EOS
    This unofficial build is ad-hoc signed and is not notarized by Apple.
    First open may require approval in System Settings > Privacy & Security.
    Enable "Convert with convt Free" in Finder Quick Actions / Services.
    The native FinderSync format submenu requires Apple team signing.
    Office conversions need: brew install --cask libreoffice
    Do not install alongside an official or manually installed convt.app.
    Homebrew does not grant Apple notarization or App Group permissions.
  EOS
end
'''.replace('VERSION', version).replace('DIGEST', digests[name]).replace('URL', assets[name])
cask = pathlib.Path('Casks/convt-free.rb'); cask.parent.mkdir(exist_ok=True)
cask.write_text(text)
print(f'Validated {tag}: {digests[name]}')
