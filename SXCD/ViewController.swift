import UIKit
import Photos
import MobileCoreServices
import CoreData

class ViewController: UITableViewController {

    private lazy var context: NSManagedObjectContext = {
        return (UIApplication.shared.delegate as! AppDelegate).context
    }()

    private lazy var sessionManager: SessionManager = {
        return (UIApplication.shared.delegate as! AppDelegate).sessionManager
    }()

    private lazy var fetchedResultsController: NSFetchedResultsController<Upload> = {

        let request = NSFetchRequest<Upload>(entityName: "Upload")
        request.sortDescriptors = [NSSortDescriptor(key: "uploadDate", ascending: false)]

        let fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        return fetchedResultsController
    }()

    @IBAction func handleNewUploadBarButtonItem(_ sender: UIBarButtonItem) {
        PHPhotoLibrary.requestAuthorization { [weak self] (status) in
            if case .authorized = status {
                DispatchQueue.main.async {
                    let picker = UIImagePickerController()
                    picker.delegate = self
                    picker.sourceType = .savedPhotosAlbum
                    picker.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String]
                    picker.videoQuality = .typeHigh
                    self?.present(picker, animated: true, completion: nil)
                }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        try! fetchedResultsController.performFetch()
        configureRefreshControl()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.fetchedObjects?.count ?? 0
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let upload = fetchedResultsController.object(at: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = upload.displayString
        return cell
    }

    private func configureRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefreshControl), for: .valueChanged)
        self.refreshControl = refreshControl
    }

    @objc func handleRefreshControl() {
        tableView.reloadData()
        refreshControl?.endRefreshing()
    }

}

extension ViewController: UINavigationControllerDelegate { }

extension ViewController: UIImagePickerControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        if let url = (info[.imageURL] ?? info[.mediaURL]) as? URL {

            let newUpload = Upload(url: url, context: context)
            try! context.save()

            sessionManager.uploadFile(newUpload)

        }

        picker.dismiss(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }


}

extension ViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {

        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .automatic)

        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .automatic)

        case .update:
            tableView.reloadRows(at: [indexPath!], with: .automatic)

        case .move:
            tableView.deleteRows(at: [indexPath!], with: .automatic)
            tableView.insertRows(at: [newIndexPath!], with: .automatic)
        }
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}
