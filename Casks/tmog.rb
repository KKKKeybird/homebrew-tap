cask "tmog" do
  version "0.1.1,20260821200548"
  sha256 "11f7e6a5d44a1590e0a9fcaa20b0936e7b0f6c029e14f7a888f0b3a7a5c88fe0"

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
