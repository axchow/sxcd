import UIKit
import CoreData

class SessionManager: NSObject {

    var backgroundCompletionHandler: (() -> Void)? = nil

    private var urlSession: URLSession!
    private var context: NSManagedObjectContext!

    
    init(id: String, context: NSManagedObjectContext) {
        super.init()
        self.context = context
        configureURLSession(id: id)
    }


    private func configureURLSession(id: String) {

        let config = URLSessionConfiguration.background(withIdentifier: id)
        config.isDiscretionary = true
        config.sharedContainerIdentifier = AppGroup.identifier

        urlSession = URLSession(configuration: config, delegate: self, delegateQueue: OperationQueue.main)

    }

    func uploadFile(_ upload: Upload) {

        #warning("External URL call - this endpoint accepts any files.")
        let uploadURL = URL(string: "https://httpbin.org/")!
        var request = URLRequest(url: uploadURL)
        request.httpMethod = "POST"

        let fileURL = URL(string: upload.urlString!)!
        let task = urlSession.uploadTask(with: request, fromFile: fileURL)
        task.taskDescription = upload.uuid
        task.resume()

    }

}

extension SessionManager: URLSessionDelegate {

    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        backgroundCompletionHandler?()
        backgroundCompletionHandler = nil
    }

}

extension SessionManager: URLSessionDataDelegate {

    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {

        print(ByteCountFormatter.string(fromByteCount: totalBytesSent, countStyle: .file))

        let request = NSFetchRequest<Upload>(entityName: "Upload")
        request.predicate = NSPredicate(format: "uuid == %@", task.taskDescription!)

        let upload = try! context.fetch(request).first!
        upload.uploadedBytes = totalBytesSent

        try! context.save()
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {

        print(#function)

        guard error == nil else {
            assertionFailure(error!.localizedDescription)
            return
        }

        let request = NSFetchRequest<Upload>(entityName: "Upload")
        request.predicate = NSPredicate(format: "uuid == %@", task.taskDescription!)

        let upload = try! context.fetch(request).first!
        upload.uploadedBytes = task.countOfBytesSent

        try! context.save()
    }

}
