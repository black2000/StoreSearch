//
//  SearchResultCell.swift
//  StoreSearch
//
//  Created by lapshop on 2/8/21.
//

import UIKit

class SearchResultCell: UITableViewCell {
    var downloadTask : URLSessionDownloadTask?
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var artworkImageView: UIImageView!

    override  func awakeFromNib() {
       super.awakeFromNib()
        let selectedView = UIView(frame: CGRect.zero)
        selectedView.backgroundColor = UIColor(red: 20/255,green: 160/255, blue: 160/255, alpha: 0.5)
        selectedBackgroundView = selectedView
    }
    
    
    func Configure(for result:SearchResult)  {
        nameLabel.text = result.name
        
        if  result.artist.isEmpty {
            artistNameLabel.text = "unknown"
        }else {
           artistNameLabel.text = String(format: "%@ (%@)",result.artist, result.type)
        }
        
        artworkImageView.image = UIImage(named: "Placeholder")
        
        if let smallURL =  URL(string: result.imageSmall) {
            downloadTask = artworkImageView.loadImage(url: smallURL)
        }
        
        
    }
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        downloadTask?.cancel()
        downloadTask = nil
    }
    
}
