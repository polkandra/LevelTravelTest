
import UIKit

class MainViewController: UIViewController, AlertDisplayer {
   
    @IBOutlet weak var emptyPlaceholderImage: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var searchBar: CustomSearchBar!

    var segmentedController: UISegmentedControl!
    var mainPresenter: MainPresenter!
    var tap: UITapGestureRecognizer!
    
    private enum SearchMode: String {
        case iTunes
        case lastFm
    }
    private var searchMode: SearchMode = .lastFm
   
    let estimatedRowHeight: CGFloat = 100.0
    
    init(mainPresenter: MainPresenter) {
        super.init(nibName: nil, bundle: nil)
        self.mainPresenter = mainPresenter
        mainPresenter.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setSegmenterdControl()
        tableView.isHidden = true
        self.hideKeyboardWhenTappedAround()
        mainPresenter.attachView(view: self)
        setTableView()
        activityIndicator?.hidesWhenStopped = true
        setSearchBar()
    }
   
    func setSearchBar() {
        searchBar.throttlingInterval = 0.5
        self.mainPresenter.itunesTracks.removeAll()
        self.mainPresenter.lastFmTracks.removeAll()
        
        searchBar.onSearch = { [weak self] text in
            if text.count > 3 {
                self?.tableView.isHidden = false
            
                switch self?.searchMode {
                    case .lastFm?: self?.mainPresenter.fetchLastFmTracks(with: text)
                    case .iTunes?: self?.mainPresenter.fetchItunesTracks(with: text)
                    default: break
                }
                
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
           
            } else {
                self?.activityIndicator.isHidden = true
                self?.tableView.isHidden = true
                self?.mainPresenter.lastFmTracks.removeAll()
                self?.mainPresenter.itunesTracks.removeAll()
                self?.mainPresenter.lastFmCurrentPage = 1
                self?.mainPresenter.itunesCurrentPage = 1
                self?.mainPresenter.lastFmIndex = 1
                self?.emptyPlaceholderImage.image = UIImage(named: "EmptyState")
            }
        }
    }
    
    func setTableView() {
        tableView.register(UINib(nibName: Constants.MainControllerNibs.lastFmContentCell, bundle: nil), forCellReuseIdentifier: Constants.MainControllerCellIdentifiers.lastFmContentCell)
        tableView.estimatedRowHeight = estimatedRowHeight
        tableView?.dataSource = self
        tableView?.delegate = self
    }
    
    func setSegmenterdControl() {
        let items = ["LastFM", "Itunes"]
        segmentedController = UISegmentedControl(items: items)
        segmentedController.selectedSegmentIndex = 0
        navigationItem.titleView = segmentedController
        navigationItem.rightBarButtonItem?.tintColor = UIColor.black
        segmentedController.addTarget(self, action: #selector(segmentTapped), for: .valueChanged)
    }

    //MARK: Actions
    @objc private func segmentTapped(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
            case 0:
                searchMode = .lastFm
                clear()
                startLoading()
                self.mainPresenter.fetchLastFmTracks(with: searchBar.text ?? "")
            
            case 1:
                searchMode = .iTunes
                clear()
                startLoading()
                self.mainPresenter.fetchItunesTracks(with: searchBar.text ?? "")
           
           default: break
        }
    }

    private func clear() {
        tableView.isHidden = true
        mainPresenter.lastFmTracks.removeAll()
        mainPresenter.itunesTracks.removeAll()
        dismissFullscreenImage(tap)
        finishLoading()
    }

    private func isLoadingIndexPath(_ indexPath: IndexPath) -> Bool {
        guard mainPresenter.isFetchInProgress  else { return false }
        switch searchMode {
            case .lastFm: return indexPath.row == mainPresenter.lastFmTotalCount
            case .iTunes: return indexPath.row == mainPresenter.iTunesTotalCount
        }
    }
   
    private func fetchNextPage() {
        switch searchMode {
            case .lastFm:
                mainPresenter.lastFmCurrentPage += 1
                mainPresenter.fetchLastFmTracks(with: searchBar.text ?? "")
            case .iTunes:
                mainPresenter.itunesCurrentPage += 1
                mainPresenter.fetchItunesTracks(with: searchBar.text ?? "")
        }
    }
}

extension MainViewController: LastFmView {
    func startLoading() {
        activityIndicator?.startAnimating()
    }
    
    func finishLoading() {
        activityIndicator?.stopAnimating()
    }
}

extension MainViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch searchMode {
            case .iTunes:
                return mainPresenter?.itunesTracks.count ?? 0
            case .lastFm:
                return mainPresenter?.lastFmTracks.count ?? 0

            }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.MainControllerCellIdentifiers.lastFmContentCell, for: indexPath) as! BaseCell
        
        switch searchMode {
            case .lastFm:
                if indexPath.row == mainPresenter.lastFmTracks.count - 1 {
                    if mainPresenter.lastFmTotalCount > mainPresenter.lastFmTracks.count {
                        fetchNextPage()
                    }
                }
                if isLoadingIndexPath(indexPath) {
                    return LoadingCell(style: .default, reuseIdentifier: Constants.MainControllerCellIdentifiers.loadingCell)
                } else {
                    cell.configureLastFmCell(with: mainPresenter.lastFmTrack(at: indexPath.row))
                }
            case .iTunes:
                if indexPath.row == mainPresenter.itunesTracks.count - 1 {
                    if mainPresenter.iTunesTotalCount > mainPresenter.itunesTracks.count {
                        fetchNextPage()
                    }
                }
                if isLoadingIndexPath(indexPath) {
                   return LoadingCell(style: .default, reuseIdentifier: Constants.MainControllerCellIdentifiers.loadingCell)
                } else {
                    cell.configureItunesCell(with: mainPresenter.iTunesTrack(at: indexPath.row))
            }
            
        }
        return cell
    }
}

extension MainViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch searchMode {
            case .lastFm:
                createImageToEnlarge(withPath: indexPath, string:  mainPresenter.lastFmTracks[indexPath.row].image[3].text)
            case .iTunes:
                createImageToEnlarge(withPath: indexPath, string:  mainPresenter.itunesTracks[indexPath.row].artworkUrl100 ?? "")
        }
    }

    @objc func dismissFullscreenImage(_ sender: UITapGestureRecognizer) {
        UIView.animate(withDuration: 0.4) {
            sender.view?.removeFromSuperview()
        }
    }

    private func createImageToEnlarge(withPath indexPath: IndexPath, string picString: String) {
        let pics = picString
        let imageView = UIImageView()
        imageView.imageFromServerURL(pics)
        
        UIView.animate(withDuration: 0.2) {
            imageView.frame = self.view.frame
        }
       
        imageView.backgroundColor = .black
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        
        tap = UITapGestureRecognizer(target: self, action: #selector(dismissFullscreenImage))
        tap.numberOfTapsRequired = 1
        
        imageView.addGestureRecognizer(tap)
        tap.cancelsTouchesInView = false
        
        self.view.addSubview(imageView)
    }

}
extension MainViewController: TracksPresenterDelegate {
    func onNothingBeenFetched() {
        self.tableView.isHidden = true
        self.emptyPlaceholderImage.image = UIImage(named: "noResults")
    }
    
    func onFetchCompleted() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.finishLoading()
            self.tableView.isHidden = false
        }
    }
    
    func onFetchFailed(with reason: String) {
        finishLoading()
        let title = "Warning"
        let action = UIAlertAction(title: "OK", style: .default)
        displayAlert(with: title , message: reason, actions: [action])
    }
}
