import Foundation
import CoreData

@objc(Upload)
public class Upload: NSManagedObject {

    convenience init(url: URL, context: NSManagedObjectContext) {
        self.init(context: context)

        self.urlString = url.absoluteString
        self.uuid = UUID().uuidString
        self.uploadDate = NSDate()

        let attributes = try! FileManager.default.attributesOfItem(atPath: url.path)
        self.fileSize = attributes[FileAttributeKey.size] as? Int64 ?? 0
        self.uploadedBytes = 0
    }


    var displayString: String {

        if uploadedBytes == fileSize {
            return "Uploaded"

        } else {
            let s1 = ByteCountFormatter.string(fromByteCount: uploadedBytes, countStyle: .file)
            let s2 = ByteCountFormatter.string(fromByteCount: fileSize, countStyle: .file)
            return "\(s1) / \(s2)"

        }
    }

}
