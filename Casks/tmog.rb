cask "tmog" do
  version "1.0.0,20260923234339"
  sha256 "78c482e598e16fa5b479e05a9609a3a4c1f78dfce960468bea77f0fb98189895"

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
