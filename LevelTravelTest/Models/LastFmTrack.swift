

import Foundation

struct LastFMTrack: Codable {
    let results: TrackFetchResults
}

struct TrackFetchResults: Codable {
    let opensearchQuery: OpensearchQuery
    let opensearchTotalResults: String
    let opensearchStartIndex: String
    let opensearchItemsPerPage: String
    let trackmatches: Trackmatches
    let attr: Attr
    
    enum ResultsCodingKeys: String, CodingKey {
        case opensearchQuery = "opensearch:Query"
        case opensearchTotalResults = "opensearch:totalResults"
        case opensearchStartIndex = "opensearch:startIndex"
        case opensearchItemsPerPage = "opensearch:itemsPerPage"
        case trackmatches
        case attr = "@attr"
    }

    init(from decoder: Decoder) throws {
        let resultsContainer = try decoder.container(keyedBy: ResultsCodingKeys.self)
        opensearchQuery = try resultsContainer.decode(OpensearchQuery.self, forKey: .opensearchQuery)
        opensearchTotalResults = try resultsContainer.decode(String.self, forKey: .opensearchTotalResults)
        opensearchStartIndex = try resultsContainer.decode(String.self, forKey: .opensearchStartIndex)
        opensearchItemsPerPage = try resultsContainer.decode(String.self, forKey: .opensearchItemsPerPage)
        trackmatches = try resultsContainer.decode(Trackmatches.self, forKey: .trackmatches)
        attr = try resultsContainer.decode(Attr.self, forKey: .attr)
    }
}

struct Attr: Codable {}

struct OpensearchQuery: Codable {
    let text, role, startPage: String
    
    enum OpensearchQueryCodingKeys: String, CodingKey {
        case text = "#text"
        case role, startPage
    }
    
    init(from decoder: Decoder) throws {
        let opensearchQueryResultsContainer = try decoder.container(keyedBy: OpensearchQueryCodingKeys.self)
        text = try opensearchQueryResultsContainer.decode(String.self, forKey: .text)
        role = try opensearchQueryResultsContainer.decode(String.self, forKey: .role)
        startPage = try opensearchQueryResultsContainer.decode(String.self, forKey: .startPage)
    }
}

struct Trackmatches: Codable {
    let track: [TrackElement]
}

struct TrackElement: Codable {
    let name, artist: String
    let url: String
    let streamable: Streamable
    let listeners: String
    let image: [Image]
    let mbid: String

    enum TrackElementCodingKeys: String, CodingKey {
        case name = "name"
        case artist = "artist"
        case url = "url"
        case streamable = "streamable"
        case listeners = "listeners"
        case image = "image"
        case mbid = "mbid"
    }

    init(from decoder: Decoder) throws {
        let trackElementCodingKeysResultsContainer = try decoder.container(keyedBy: TrackElementCodingKeys.self)
        name = try trackElementCodingKeysResultsContainer.decode(String.self, forKey: .name)
        artist = try trackElementCodingKeysResultsContainer.decode(String.self, forKey: .artist)
        url = try trackElementCodingKeysResultsContainer.decode(String.self, forKey: .url)
        streamable = try trackElementCodingKeysResultsContainer.decode(Streamable.self, forKey: .streamable)
        listeners = try trackElementCodingKeysResultsContainer.decode(String.self, forKey: .listeners)
        image = try trackElementCodingKeysResultsContainer.decode([Image].self, forKey: .image)
        mbid = try trackElementCodingKeysResultsContainer.decode(String.self, forKey: .mbid)
    }
}

struct Image: Codable {
    let text: String
    let size: Size
    
    enum ImageCodingKeys: String, CodingKey {
        case text = "#text"
        case size
    }

    init(from decoder: Decoder) throws {
        let imageCodingKeysResultsContainer = try decoder.container(keyedBy: ImageCodingKeys.self)
        text = try imageCodingKeysResultsContainer.decode(String.self, forKey: .text)
        size = try imageCodingKeysResultsContainer.decode(Size.self, forKey: .size)
       
    }
}

enum Size: String, Codable {
    case extralarge = "extralarge"
    case large = "large"
    case medium = "medium"
    case small = "small"
}

enum Streamable: String, Codable {
    case fixme = "FIXME"
}
