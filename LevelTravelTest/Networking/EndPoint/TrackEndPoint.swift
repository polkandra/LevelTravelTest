
import Foundation

public enum TrackApi {
    case track(name: String, page: Int)
}

extension TrackApi: EndPointType {
    var baseURL: URL {
        guard let url = URL(string: "http://ws.audioscrobbler.com") else { fatalError("baseURL could not be configured.") }
        
        return url
    }
    
    var path: String {
        switch self {
        case .track:
            return "/2.0/"
        }
    }
    
    var httpMethod: HTTPMethod {
        return .get
    }
    
    var task: HTTPTask {
        switch self {
        case .track(let name, let page):
            return .requestParameters(bodyParameters: nil, bodyEncoding: .urlEncoding, urlParameters:
                ["method" : "track.search",
                 "api_key" : Constants.LASTFM_API_KEY,
                 "track" : name, "format" : "json",
                 "page" : page,
                 "limit" : "30"])
        }
    }
    
    var headers: HTTPHeaders? {
        return nil
    }
}
