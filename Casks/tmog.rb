cask "tmog" do
  version "0.1.0,20260731155640"
  sha256 "836b35dd941b92fdad609f835390953b8db13d86878c44a0e2083525ac5fb5ec"

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
