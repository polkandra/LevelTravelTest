import Foundation
import UIKit

protocol TracksPresenterDelegate: class {
    func onFetchCompleted()
    func onFetchFailed(with reason: String)
    func onNothingBeenFetched()
}

protocol LastFmView: NSObjectProtocol {
    func startLoading()
    func finishLoading()
    func fillWithTracks(tracks: [TrackElement])
    func showEmptyResultsView()
}

class MainPresenter {
    
    weak private var lastFmView: LastFmView?
    let networkManager: NetworkManager!
    weak var delegate: TracksPresenterDelegate?
    var lastFmTracks: [TrackElement] = []
    var itunesTracks: [ItunesTrackPayload] = []
    var lastFmCurrentPage = 1
    var itunesCurrentPage = 1
    var lastFmIndex = 1
    private var lastFmTotal = 0
    private var iTunesTotal = 0
    var isFetchInProgress = false
    
    init(networkManager: NetworkManager) {
        self.networkManager = networkManager
    }
    
    var lastFmTotalCount: Int {
        return lastFmTotal
    }
    
    var iTunesTotalCount: Int {
        return iTunesTotal
    }
   
    var currentCount: Int {
        return lastFmTracks.count
    }
    
    func lastFmTrack(at index: Int) -> TrackElement {
        return lastFmTracks[index]
    }
    
    func iTunesTrack(at index: Int) -> ItunesTrackPayload {
        return itunesTracks[index]
    }
    
    func attachView(view: LastFmView){
        lastFmView = view
    }
   
    func detachView() {
        lastFmView = nil
    }
    
    public func fetchLastFmTracks(with name: String = "") {
        self.lastFmView?.startLoading()
       
        guard !isFetchInProgress else {
            return
        }
      
        isFetchInProgress = true
        
        networkManager.getLastFmTracks(name: name, page: lastFmCurrentPage) { [weak self] (allTracks, total, index, error) in
            if error != nil {
                DispatchQueue.main.async {
                    self?.isFetchInProgress = false
                    self?.delegate?.onFetchFailed(with: error!)
                    self?.lastFmIndex = 0
                }
            }
            DispatchQueue.main.async {
                if let tracks = allTracks, let total = total, let index = index {
                    self?.lastFmTracks.append(contentsOf: tracks)
                    self?.isFetchInProgress = false
                    self?.lastFmTotal = Int(total) ?? 0
                    self?.lastFmIndex = Int(index) ?? 0
                    self?.delegate?.onFetchCompleted()
                
                    if self?.lastFmTotal == 0 {
                        self?.delegate?.onNothingBeenFetched()
                    }
                }
            }
        }
    }

    public func fetchItunesTracks(with name: String = "") {
        self.lastFmView?.startLoading()
        
        guard !isFetchInProgress else {
            return
        }
        
        isFetchInProgress = true
        
        networkManager.getItunesTracks(name: name) { [weak self] (allItunesTracks, totalResults, error) in
            if error != nil {
                DispatchQueue.main.async {
                    self?.isFetchInProgress = false
                }
            }
            DispatchQueue.main.async {
                if let tracks = allItunesTracks, let total = totalResults {
                    self?.itunesTracks.append(contentsOf: tracks)
                    self?.isFetchInProgress = false
                    self?.iTunesTotal = Int(total)
                    self?.delegate?.onFetchCompleted()
                   
                    if self?.iTunesTotal == 0 {
                        self?.delegate?.onNothingBeenFetched()
                    }
                }
            }
        }
    }
}
