import UIKit
import SnapKit

// MARK: - ChipsRow
final class ChipsRow: UIView {
    private let scroll = UIScrollView()
    private let stack = UIStackView()

    var onTap: ((String) -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setup() {
        scroll.showsHorizontalScrollIndicator = false
        addSubview(scroll)
        scroll.snp.makeConstraints { $0.edges.equalToSuperview() }

        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 4
        scroll.addSubview(stack)
        stack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalToSuperview()
        }
    }

    func set(titles: [String]) {
        stack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for title in titles {
            let b = UIButton(type: .system)
            b.setTitle(title, for: .normal)

            if let montserrat = UIFont(name: "Montserrat-SemiBold", size: 12) {
                let paragraph = NSMutableParagraphStyle()
                paragraph.minimumLineHeight = 16
                paragraph.maximumLineHeight = 16
                let attributed = NSAttributedString(
                    string: title,
                    attributes: [
                        .font: montserrat,
                        .paragraphStyle: paragraph,
                        .kern: 0
                    ])
                b.setAttributedTitle(attributed, for: .normal)
            } else {
                b.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
            }

            b.setTitleColor(.black, for: .normal)
            b.backgroundColor = UIColor(white: 0.95, alpha: 1)
            b.layer.cornerRadius = 20
            b.contentEdgeInsets = UIEdgeInsets(top: 0, left: 14, bottom: 0, right: 14)
            b.snp.makeConstraints { $0.height.equalTo(40) }

            b.addAction(UIAction { [weak self, weak b] _ in
                guard let btn = b else { return }
                UIView.animate(withDuration: 0.08, animations: {
                    btn.transform = CGAffineTransform(scaleX: 0.96, y: 0.96)
                }, completion: { _ in
                    UIView.animate(withDuration: 0.08) { btn.transform = .identity }
                })
                self?.onTap?(title)
            }, for: .touchUpInside)

            stack.addArrangedSubview(b)
        }
    }
}

// MARK: - SearchViewController
final class SearchViewController: UIViewController, UITextFieldDelegate {
    
    private var allStocks: [Stock] = [] // данные из API
    
    // MARK: - Custom SearchBar
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
    
    private let textField: UITextField = {
        let tf = UITextField()
        tf.placeholder = ""
        tf.textColor = .black
        tf.tintColor = .black
        tf.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        return tf
    }()
    
    private let clearButton: UIButton = {
        let b = UIButton(type: .system)
        b.setImage(UIImage(named: "close"), for: .normal)
        b.tintColor = .black
        b.isHidden = true
        return b
    }()
    
    private let popularLabel: UILabel = {
        let l = UILabel()
        l.text = "Popular requests"
        l.font = UIFont(name: "Montserrat-Bold", size: 20) ?? .boldSystemFont(ofSize: 20)
        l.textColor = .black
        return l
    }()
    
    private let historyLabel: UILabel = {
        let l = UILabel()
        l.text = "You’ve searched for this"
        l.font = UIFont(name: "Montserrat-Bold", size: 20) ?? .boldSystemFont(ofSize: 20)
        l.textColor = .black
        return l
    }()
    
    private let popularRow1 = ChipsRow()
    private let popularRow2 = ChipsRow()
    private let historyRow1 = ChipsRow()
    private let historyRow2 = ChipsRow()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupSearchBar()
        setupLayout()
        setupContent()
        fetchStocks() // загрузка с API
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        textField.becomeFirstResponder()
    }
    
    // MARK: - API
    private func fetchStocks() {
        guard let url = URL(string: "https://example.com/api/stocks") else { return }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let data, error == nil else { return }
            do {
                let decoded = try JSONDecoder().decode([Stock].self, from: data)
                DispatchQueue.main.async {
                    self?.allStocks = decoded
                }
            } catch {
                print("decode error: \(error)")
            }
        }.resume()
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
        }, for: .touchUpInside)
        
        textField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
    }
    
    // MARK: - Layout секций
    private func setupLayout() {
        view.addSubview(popularLabel)
        popularLabel.snp.makeConstraints { make in
            make.top.equalTo(searchContainer.snp.bottom).offset(16)
            make.left.equalToSuperview().offset(16)
        }
        
        view.addSubview(popularRow1)
        popularRow1.snp.makeConstraints { make in
            make.top.equalTo(popularLabel.snp.bottom).offset(8)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview()
            make.height.equalTo(40)
        }
        
        view.addSubview(popularRow2)
        popularRow2.snp.makeConstraints { make in
            make.top.equalTo(popularRow1.snp.bottom).offset(8)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview()
            make.height.equalTo(40)
        }
        
        view.addSubview(historyLabel)
        historyLabel.snp.makeConstraints { make in
            make.top.equalTo(popularRow2.snp.bottom).offset(24)
            make.left.equalToSuperview().offset(16)
        }
        
        view.addSubview(historyRow1)
        historyRow1.snp.makeConstraints { make in
            make.top.equalTo(historyLabel.snp.bottom).offset(8)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview()
            make.height.equalTo(40)
        }
        
        view.addSubview(historyRow2)
        historyRow2.snp.makeConstraints { make in
            make.top.equalTo(historyRow1.snp.bottom).offset(8)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview()
            make.height.equalTo(40)
        }
    }
    
    private func setupContent() {
        popularRow1.set(titles: ["Apple", "Tesla", "Amazon", "Microsoft", "Google", "First Solar"])
        popularRow2.set(titles: ["Alibaba", "Facebook", "Mastercard", "Cisco", "Nvidia", "Nokia", "Yandex", "GM"])
        
        historyRow1.set(titles: ["Nvidia", "Nokia", "Yandex", "GM", "Baidu", "Intel", "AMD", "Visa", "Bank of America"])
        historyRow2.set(titles: ["Amazon", "Google", "Tesla", "Microsoft", "First Solar", "Alibaba", "Facebook", "Mastercard", "Cisco"])
        
        let handler: (String) -> Void = { [weak self] text in
            guard let self else { return }
            self.textField.text = text
            self.textDidChange()
        }
        popularRow1.onTap = handler
        popularRow2.onTap = handler
        historyRow1.onTap = handler
        historyRow2.onTap = handler
    }
    
    // MARK: - Actions
    @objc private func textDidChange() {
        clearButton.isHidden = (textField.text ?? "").isEmpty
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        guard let query = textField.text, !query.isEmpty else { return true }
        
        // Сохраняем в историю
        saveToHistory(query)
        
        // Фильтруем акции
        let filteredStocks = allStocks.filter { stock in
            stock.name.lowercased().contains(query.lowercased()) ||
            stock.symbol.lowercased().contains(query.lowercased())
        }

        // Переход к SearchResultViewController
        let vc = SearchResultViewController()
        vc.stocks = filteredStocks  // используем filteredStocks
        vc.initialSearchText = query
        navigationController?.pushViewController(vc, animated: true)
        return true

    }
    
    // MARK: - История поиска
    private func saveToHistory(_ query: String) {
        var history = UserDefaults.standard.stringArray(forKey: "searchHistory") ?? []
        if !history.contains(query) {
            history.insert(query, at: 0)
            if history.count > 20 { history.removeLast() } // максимум 20 записей
            UserDefaults.standard.set(history, forKey: "searchHistory")
        }
    }
    
    // MARK: - Загрузка истории в ChipsRow
    private func loadHistory() {
        let history = UserDefaults.standard.stringArray(forKey: "searchHistory") ?? []
        let firstRow = Array(history.prefix(9))
        let secondRow = Array(history.dropFirst(9).prefix(9))
        
        historyRow1.set(titles: firstRow)
        historyRow2.set(titles: secondRow)
        
        let handler: (String) -> Void = { [weak self] text in
            guard let self else { return }
            self.textField.text = text
            self.textFieldShouldReturn(self.textField)
        }
        
        historyRow1.onTap = handler
        historyRow2.onTap = handler
    }
}
