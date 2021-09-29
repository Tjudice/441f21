import UIKit

final class ChattTableCell: UITableViewCell {

    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    
    @IBOutlet weak var chattImageView: UIImageView!
    

    @IBOutlet weak var videoButton: UIButton!
    
    var playVideo: (() -> Void)?  // a closure
    @IBAction func videoTapped(_ sender: Any) {
        self.playVideo?()
    }

}
