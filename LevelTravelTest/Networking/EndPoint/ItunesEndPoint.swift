

import Foundation

public enum ItunesApi {
    case track(name: String)
}

extension ItunesApi: EndPointType {
    var baseURL: URL {
        guard let url = URL(string: "https://itunes.apple.com/") else { fatalError("baseURL could not be configured.") }
        
        return url
    }
    
    var path: String {
        switch self {
        case .track:
            return "search"
        }
    }
    
    var httpMethod: HTTPMethod {
        return .get
    }
    
    var task: HTTPTask {
        switch self {
        case .track(let name):
            return .requestParameters(bodyParameters: nil, bodyEncoding: .urlEncoding, urlParameters:
                ["term" : name,
                 "limit" : 200])
        }
    }
    
    var headers: HTTPHeaders? {
        return nil
    }
}
