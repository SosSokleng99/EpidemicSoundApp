//
//  Extensions.swift
//  EpedimicSound
//
//  Created by Danilo Rivera on 12/23/18.
//  Copyright © 2018 Danilo Rivera. All rights reserved.
//

import UIKit

extension   UIView {
    
    func addConstraintWithFormat(format: String, views: UIView...) {
        
        var viewsDictionary =   [String: UIView]()
        for (index, view) in views.enumerated() {
            let key =   "v\(index)"
            view.translatesAutoresizingMaskIntoConstraints  =   false
            viewsDictionary[key]    =   view
        }
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: viewsDictionary))
    }
    
    
}

//Class to handle Image Cache from Firebase Storage
let imgCache = NSCache<AnyObject, AnyObject>()
class CustomImg: UIImageView {
    var imgURLString: String?
    func locateURLImg(urlString: String) {
        imgURLString = urlString
        let url = NSURL(string: urlString)
        image = nil
        if let imgFromCache = imgCache.object(forKey: urlString as AnyObject) as? UIImage {
            self.image = imgFromCache
            return
        }
        URLSession.shared.dataTask(with: url! as URL, completionHandler: {(data, response, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            DispatchQueue.main.async {
                
                let imgToCache = UIImage(data: data!)
                if self.imgURLString == urlString {
                    self.image = imgToCache
                }
                imgCache.setObject(imgToCache!, forKey: urlString as AnyObject)
            }
        }).resume()
    }
}



