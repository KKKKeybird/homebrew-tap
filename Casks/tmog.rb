cask "tmog" do
  version "1.1.0,20261026015153"
  sha256 "e233c033514c703f19fafa394f99f2679e89ed88f1b74fc9f03574dc6b1bea64"

  url "https://www.tmog.org/downloads/TMOG-Task-Manager-#{version.csv.first}-#{version.csv.second}-macOS-universal.dmg"
  name "Task Manager TMOG"
  desc "System task manager and performance monitor"
  homepage "https://www.tmog.org/"

  livecheck do
    url "https://www.tmog.org/downloads/release.json"
    strategy :json do |json|
      "#{json["version"]},#{json["build"]}"
    end
  end

  depends_on macos: :sonoma

  app "Task Manager TMOG.app"
end
