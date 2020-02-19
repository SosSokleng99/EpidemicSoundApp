//
//  EpidemicSound-Backup.swift
//  Tracks
//
//  Created by Danilo Rivera on 12/1/2020.
//  Copyright © 2020 Danilo Rivera. All rights reserved.
//

import Foundation

protocol Identifiable {
    var id: String? { get set }
}

struct Track: Codable, Identifiable {
    var id: String? = nil
    var title: String
    var duration: String
    var artist: String
    var genere: String
    var order: Int
    let audio_url: String
    let album_cover: String
    
    init(title: String, artist: String, duration: String ,genere: String, order: Int, audio_url: String, album_cover: String) {
        self.title = title
        self.artist = artist
        self.duration = duration
        self.genere = genere
        self.order = order
        self.audio_url = audio_url
        self.album_cover = album_cover
    }
    
}


