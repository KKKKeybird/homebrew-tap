cask "tmog" do
  version "0.1.4,20260916001402"
  sha256 "b89aa98f75303dd5a21cdf1be491ccfc956c650051d1c2bb3e6882eaf6e08d57"

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
