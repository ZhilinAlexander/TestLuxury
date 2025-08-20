import UIKit
import SnapKit

final class SearchResultViewController: UIViewController {

    // MARK: - Data
    var stocks: [Stock] = []
    private var filteredStocks: [Stock] = []
    var isSearching = false
    
    private var allStocks: [Stock] = []       // полный список с API

    // MARK: - Saved search text
    var initialSearchText: String?
    
    // MARK: - UI
    private let stockSection = StockSectionView()

    // MARK: - Callbacks
    var onShowMoreStocks: (() -> Void)?

    // Search UI
    private let searchContainer: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 25
        v.layer.borderWidth = 2
        v.layer.borderColor = UIColor.black.cgColor
        v.backgroundColor = .white
        v.clipsToBounds = true
        return v
    }()
    
    private let backButton: UIButton = {
        let b = UIButton(type: .system)
        b.setImage(UIImage(named: "Back"), for: .normal)
        b.tintColor = .black
        return b
    }()
    
    private let clearButton: UIButton = {
        let b = UIButton(type: .system)
        b.setImage(UIImage(named: "close"), for: .normal)
        b.tintColor = .black
        b.isHidden = true
        return b
    }()
    
    private let textField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Search stocks"
        tf.font = UIFont.systemFont(ofSize: 16)
        tf.borderStyle = .none
        return tf
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupSearchBar()
        setupSections()
        restoreInitialSearchText()
        loadStocks()
    }
    
    private func setupSections() {
        view.addSubview(stockSection)

        stockSection.snp.makeConstraints { make in
            make.top.equalTo(searchContainer.snp.bottom).offset(12)
            make.left.right.bottom.equalToSuperview()
        }

        stockSection.title = "Stocks"
        stockSection.stocks = stocks

        stockSection.onShowMore = { [weak self] in
            print("➡️ Show more stocks")
            self?.onShowMoreStocks?()
        }
    }

    // MARK: - Restore initial text
    private func restoreInitialSearchText() {
        guard let text = initialSearchText, !text.isEmpty else { return }
        textField.text = text
        isSearching = true
        clearButton.isHidden = false
        applyFilter(text)
    }

    // MARK: - Setup SearchBar
    private func setupSearchBar() {
        view.addSubview(searchContainer)
        searchContainer.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(25)
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
            make.height.equalTo(48)
        }

        searchContainer.addSubview(backButton)
        backButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(12)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(24)
        }

        searchContainer.addSubview(clearButton)
        clearButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-12)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(24)
        }

        searchContainer.addSubview(textField)
        textField.snp.makeConstraints { make in
            make.left.equalTo(backButton.snp.right).offset(8)
            make.right.equalTo(clearButton.snp.left).offset(-8)
            make.centerY.equalToSuperview()
            make.height.equalTo(40)
        }

        textField.delegate = self
        backButton.addAction(UIAction { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }, for: .touchUpInside)

        clearButton.addAction(UIAction { [weak self] _ in
            self?.textField.text = ""
            self?.clearButton.isHidden = true
            self?.isSearching = false
            self?.updateSections(with: self?.stocks ?? [])
        }, for: .touchUpInside)

        textField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
    }

    @objc private func textDidChange() {
        guard let text = textField.text, !text.isEmpty else {
            isSearching = false
            clearButton.isHidden = true
            updateSections(with: stocks)
            return
        }
        isSearching = true
        clearButton.isHidden = false
        applyFilter(text)
    }

    private func applyFilter(_ query: String) {
        print("🔍 Filtering query: \(query)")
        let matched = allStocks.filter {
            $0.symbol.lowercased().contains(query.lowercased()) ||
            $0.name.lowercased().contains(query.lowercased())
        }
        print("✅ Found matches: \(matched.count)")
        matched.forEach { print("   \($0.name)") }
        
        filteredStocks = matched.filter { $0.type == "stock" }
        stockSection.stocks = filteredStocks
    }

    // MARK: - API
    private func loadStocks() {
        guard let url = URL(string: "https://mustdev.ru/api/stocks.json") else { return }
        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let data = data, error == nil else { return }
            do {
                let result = try JSONDecoder().decode([Stock].self, from: data)
                DispatchQueue.main.async {
                    self?.allStocks = result
                    self?.updateSections(with: result)   // обновляем UI
                }
            } catch {
                print("JSON parse error: \(error)")
            }
        }.resume()
    }

    // MARK: - Update UI sections
    private func updateSections(with stocks: [Stock]) {
        let stockItems = stocks.filter { $0.type == "stock" }
        stockSection.stocks = stockItems
    }
}

// MARK: - UITextFieldDelegate
extension SearchResultViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
