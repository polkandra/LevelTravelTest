

import Foundation

enum NetworkResponse:String {
    case success
    case authenticationError = "You need to be authenticated first."
    case badRequest = "Bad request"
    case outdated = "The url you requested is outdated."
    case failed = "Network request failed."
    case noData = "Response returned with no data to decode."
    case unableToDecode = "We could not decode the response."
}

enum Result<String>{
    case success
    case failure(String)
}

struct NetworkManager {
   
    let lastFmRouter = Router<TrackApi>()
    let iTunesRouter = Router<ItunesApi>()
    
   
    func getLastFmTracks(name:
        String, page: Int,
                completion:
                @escaping (_ track: [TrackElement]?,
                _ total: String?,
                _ index: String?,
                _ error: String?) -> ()) {
        lastFmRouter.request(.track(name: name, page: page)) { data, response, error in
            if error != nil {
                completion(nil, "0", "0","Please check your network connection.")
            }
            
            if let response = response as? HTTPURLResponse {
                let result = self.handleNetworkResponse(response)
                
                switch result {
                
                case .success:
                    guard let responseData = data else {
                        completion(nil, "0", "0", NetworkResponse.noData.rawValue)
                        return
                    }
                    do {
                        print(responseData)
                        let jsonData = try JSONSerialization.jsonObject(with: responseData, options: .mutableContainers)
                        print(jsonData)
                        let apiResponse = try JSONDecoder().decode(LastFMTrack.self, from: responseData)
                        
                        completion(apiResponse.results.trackmatches.track, apiResponse.results.opensearchTotalResults, apiResponse.results.opensearchQuery.startPage, nil)
                    
                    }catch {
                        print(error)
                        completion(nil, "0", "0", NetworkResponse.unableToDecode.rawValue)
                    }
               
                case .failure(let networkFailureError):
                    completion(nil, "0", "0", networkFailureError)
                }
            }
        }
    }
    
    func getItunesTracks(name: String,
                         completion:
                         @escaping (_ track: [ItunesTrackPayload]?,
                        _ total: Int?,
                        _ error: String?) -> ()) {
       
        iTunesRouter.request(.track(name: name)) { data, response, error in
            if error != nil {
                completion(nil, 0, "error")
            }
            
            if let response = response as? HTTPURLResponse {
                let result = self.handleNetworkResponse(response)
                
                switch result {
                    
                case .success:
                    guard let responseData = data else {
                        completion(nil, 0 , NetworkResponse.noData.rawValue)
                        return
                    }
                    do {
                        print(responseData)
                        let jsonData = try JSONSerialization.jsonObject(with: responseData, options: .mutableContainers)
                        print(jsonData)
                        let apiResponse = try JSONDecoder().decode(ItunesTrack.self, from: responseData)
                        completion(apiResponse.results, apiResponse.resultCount, nil)
                    }catch {
                        print(error)
                        completion(nil, 0, NetworkResponse.unableToDecode.rawValue)
                    }
                    
                case .failure(let networkFailureError):
                    completion(nil, 0, networkFailureError)
                }
            }
        }
    }
    
    
    func handleNetworkResponse(_ response: HTTPURLResponse) -> Result<String>{
        switch response.statusCode {
        case 200...299: return .success
        case 401...500: return .failure(NetworkResponse.authenticationError.rawValue)
        case 501...599: return .failure(NetworkResponse.badRequest.rawValue)
        case 600: return .failure(NetworkResponse.outdated.rawValue)
        default: return .failure(NetworkResponse.failed.rawValue)
        }
    }
}
