

import Foundation


struct ItunesTrack: Codable {
    let resultCount: Int
    let results: [ItunesTrackPayload]
}

struct ItunesTrackPayload: Codable {
    
    var type, wrapperType, kind: String?
    var genreName, country, releaseDate :String?
    var description, longDescription: String?
    var artistName, collectionName, trackName, artistId:String?
    var collectionId, trackId :Int?
    var trackTimeMillis, trackCount, trackNumber, discCount, discNumber :Int?
    var artworkUrl100, previewUrl :String?
    var collectionPrice: Int?
    
    private enum CodingKeys: String, CodingKey {
        case type, wrapperType, kind
        case genreName = "primaryGenreName", country, releaseDate
        case description, longDescription
        case artistName, collectionName = "collectionCensoredName", trackName  = "trackCensoredName"
        case collectionId, trackId, artistId
        case trackTimeMillis, trackCount, trackNumber, discCount, discNumber
        case artworkUrl100, previewUrl
        case collectionPrice
    }
    
    public init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.type = try? container.decode(String.self, forKey: .type)
        self.wrapperType = try? container.decode(String.self, forKey: .wrapperType)
        self.kind = try? container.decode(String.self, forKey: .kind)
        self.genreName = try? container.decode(String.self, forKey: .genreName)
        self.country = try? container.decode(String.self, forKey: .country)
        self.releaseDate = try? container.decode(String.self, forKey: .releaseDate)
        self.description = try? container.decode(String.self, forKey: .description)
        self.longDescription = try? container.decode(String.self, forKey: .longDescription)
        self.artistName = try? container.decode(String.self, forKey: .artistName)
        self.collectionName = try? container.decode(String.self, forKey: .collectionName)
        self.trackName = try? container.decode(String.self, forKey: .trackName)
        self.artworkUrl100 = try? container.decode(String.self, forKey: .artworkUrl100)
        self.previewUrl = try? container.decode(String.self, forKey: .previewUrl)
        self.collectionId = try? container.decode(Int.self, forKey: .collectionId)
        self.trackId = try? container.decode(Int.self, forKey: .trackId)
        self.trackTimeMillis = try? container.decode(Int.self, forKey: .trackTimeMillis)
        self.trackCount = try? container.decode(Int.self, forKey: .trackCount)
        self.trackNumber = try? container.decode(Int.self, forKey: .trackNumber)
        self.discCount = try? container.decode(Int.self, forKey: .discCount)
        self.discNumber = try? container.decode(Int.self, forKey: .discNumber)
        self.collectionPrice = try? container.decode(Int.self, forKey: .collectionPrice )
    }
}
