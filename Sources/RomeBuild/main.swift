import CommandLineKit
import Foundation
import RomeKit
import Alamofire

let env = ProcessInfo.processInfo.environment

if let baseUrl = env["ROME_ENDPOINT"], let apiKey = env["ROME_KEY"] {
    let bootstrap = RomeKit.Bootstrap.init(baseUrl: baseUrl, apiKey: apiKey)
    bootstrap?.start()
} else {
    print("Environment variables ROME_ENDPOINT & ROME_KEY not set")
}

let cli = CommandLine()
var build = BoolOption(shortFlag: "b",
                       longFlag: "build",
                       helpMessage: "Fetches builds from Rome server and builds the rest using Carthage")

let platform = StringOption(shortFlag: "p",
                                 longFlag: "platform",
                                 required: false,
                                 helpMessage: "Choose between: osx,ios,watchos,tvos")

let upload = BoolOption(shortFlag: "u",
                        longFlag: "upload",
                        helpMessage: "Runs the archive command on every repository and uploads the specific version on Rome server")

let uploadSelf = MultiStringOption(shortFlag: "s",
                                 longFlag: "self",
                                 required: false,
                                 helpMessage: "Builds & uploads self, requires product name & revision parameters")

let help = BoolOption(shortFlag: "h",
                      longFlag: "help",
                      helpMessage: "Gives a list of supported operations")

cli.addOptions(build, platform, upload, uploadSelf, help)

do {
    try cli.parse()
    
    let additionalArguments = cli.unparsedArguments.filter {$0 != "--"}
    
    if build.value {
        BuildCommand().build(platforms: platform.value, additionalArguments: additionalArguments)
    } else if upload.value {
        if let uploadSelfParameters = uploadSelf.value {
            if uploadSelfParameters.count == 2 {
                UploadSelfCommand().upload(productName: uploadSelfParameters[0], revision: uploadSelfParameters[1], platforms: platform.value, additionalArguments: additionalArguments)
            } else {
                print("Uploading self requires product name & revision parameters")
            }
        } else {
            UploadCommand().upload(platforms: platform.value, additionalArguments: additionalArguments)
        }
    } else {
        HelpCommand().printHelp()
    }
    
} catch {
    cli.printUsage(error)
    exit(EX_USAGE)
}
