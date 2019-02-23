

import UIKit

class BaseCell: UITableViewCell {

    let identifier = "BaseCell"
    
    @IBOutlet weak var contentListeners: UILabel!
    @IBOutlet weak var contentOwner: UILabel!
    @IBOutlet weak var contentName: UILabel!
    @IBOutlet weak var contentAvatar: UIImageView!
    @IBOutlet weak var likeImage: UIImageView!
  
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        contentListeners.text = ""
        contentOwner.text = ""
        contentName.text = ""
        contentAvatar.image = nil
        likeImage.image = nil
    }

    func configureLastFmCell(with track: TrackElement?) {
        if let track = track {
            contentView.backgroundColor = .black
            contentListeners.textColor = .white
            contentOwner.textColor = .white
            contentName.textColor = .white
            likeImage.isHidden = false
            contentName.text = track.name
            contentOwner.text = track.artist
            contentAvatar.imageFromServerURL(track.image[3].text)
            contentListeners.text = track.listeners
        } else {

        }
    }

    func configureItunesCell(with track: ItunesTrackPayload?) {
        if let track = track {
            contentView.backgroundColor = .white
            contentListeners.textColor = .black
            contentOwner.textColor = .black
            contentName.textColor = .black
            likeImage.isHidden = true
            contentListeners.text = track.country
            contentName.text = track.collectionName
            contentOwner.text = track.artistName
            contentAvatar.imageFromServerURL(track.artworkUrl100 ?? "")
        } else {
            
        }
    }
}


