cask "tmog" do
  version "0.1.3,20260906032818"
  sha256 "aca8fefeb80288eff67bc926565c8d9ae6f02525bc8fb189f8995eeef5d1a271"

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

  depends_on macos: :ventura

  app "Task Manager TMOG.app"
end
