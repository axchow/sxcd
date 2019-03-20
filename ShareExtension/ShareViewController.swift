import UIKit
import Social
import CoreData

class ShareViewController: SLComposeServiceViewController {

    private var upload: Upload!
    
    private lazy var sessionManager: SessionManager = {
        let id = UUID().uuidString
        return SessionManager(id: id, context: context)
    }()


    override func presentationAnimationDidFinish() {

        let extensionItem = extensionContext!.inputItems.first! as! NSExtensionItem
        let attachment = extensionItem.attachments!.first!

        let fileType = attachment.registeredTypeIdentifiers.first!

        if attachment.hasRepresentationConforming(toTypeIdentifier: fileType) {
            attachment.loadFileRepresentation(forTypeIdentifier: fileType, completionHandler: { (originalURL, error) in

                guard let originalURL = originalURL, error == nil else {
                    fatalError(error!.localizedDescription)
                }

                let copyURL = AppGroup.directory.appendingPathComponent(UUID().uuidString, isDirectory: false)
                try! FileManager.default.copyItem(at: originalURL, to: copyURL)

                DispatchQueue.main.async {
                    self.upload = Upload(url: copyURL, context: self.context)
                }

            })
        }

    }

    override func didSelectPost() {

        try! context.save()
        sessionManager.uploadFile(upload)

        // Inform the host that we're done, so it un-blocks its UI. Note: Alternatively you could call super's -didSelectPost, which will similarly complete the extension context.
        self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
    }

    override func didSelectCancel() {
        context.reset()
    }

    override func configurationItems() -> [Any]! {
        // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
        return []
    }


    // MARK: - Core Data stack

    private lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {

        let persistentStoreURL = AppGroup.directory.appendingPathComponent("SXCD.sqlite", isDirectory: false)

        let modelURL = Bundle.main.url(forResource: "SXCD", withExtension: "momd")!
        let model = NSManagedObjectModel(contentsOf: modelURL)!
        let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: model)

        let options = [NSMigratePersistentStoresAutomaticallyOption: true,
                       NSInferMappingModelAutomaticallyOption: true]
        try! persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: persistentStoreURL, options: options)

        return persistentStoreCoordinator
    }()

    lazy var context: NSManagedObjectContext = {
        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.persistentStoreCoordinator = persistentStoreCoordinator
        return context
    }()


}
