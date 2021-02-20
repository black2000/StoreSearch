//
//  UIImageView+DownloadImage.swift
//  StoreSearch
//
//  Created by lapshop on 2/20/21.
//

import Foundation
import UIKit


extension UIImageView {
    func loadImage(url : URL) -> URLSessionDownloadTask  {
        
        let session = URLSession.shared
        
        let downloadTask =  session.downloadTask(with: url) { [weak self] url , response , error in
            if  error == nil ,
                let url = url ,
                let data = try? Data(contentsOf: url) ,
                let image = UIImage(data: data) {
                
                DispatchQueue.main.async {
                    if let weakself = self {
                        weakself.image = image
                    }
                }
            }
        }
        
        downloadTask.resume()
        return downloadTask
    }
}
