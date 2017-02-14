import Foundation
import RomeKit

struct UploadSelfCommand {
    
    func upload(productName: String, revision: String, platforms: String?, additionalArguments: [String]) {
        
        if !Cartfile().exists() {
            Carthage(["update", "--no-build"]+filterAdditionalArgs("update", args: additionalArguments))
        } else {
            Carthage(["bootstrap", "--no-build"]+filterAdditionalArgs("bootstrap", args: additionalArguments))
        }
        
        print("Building \(productName) for archive")
        
        var buildArchive = ["build", "--no-skip-current"]
        
        if let buildPlatforms = platforms {
            buildArchive.append("--platform")
            buildArchive.append(buildPlatforms)
        }
        buildArchive.appendContentsOf(filterAdditionalArgs("build", args: additionalArguments))
        
        Carthage(buildArchive)
        let status = Carthage(["archive"]+filterAdditionalArgs("archive", args: additionalArguments))
        
        Helpers().uploadAsset(productName, revision: revision, filePath: getFrameworkPath(status))
        print("Upload complete")
        
    }
    
}
