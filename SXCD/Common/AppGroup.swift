import Foundation

enum AppGroup {

    #warning("TODO: Change this to your App Group")
    static let identifier: String = "group.net.inoxygen.SXCD"

    static var directory: URL {
        return FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: identifier)!
    }

}
