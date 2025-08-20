import UIKit
import SnapKit

final class CategoryButtonsView: UIView {

    var categories: [String] = [] {
        didSet { createButtons() }
    }

    var selectedCategory: String? {
        didSet { updateSelection() }
    }

    var onSelectCategory: ((String) -> Void)?

    private var buttons: [UIButton] = []
    private var stack: UIStackView?

    private func createButtons() {
        // Удаляем старый стек
        stack?.removeFromSuperview()
        buttons.removeAll()

        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .fill
        stack.distribution = .fillEqually
        stack.spacing = 8

        addSubview(stack)
        stack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        self.stack = stack

        for title in categories {
            let button = UIButton(type: .system)
            button.setTitle(title, for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
            button.layer.cornerRadius = 8
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor.systemGray4.cgColor
            button.setTitleColor(.label, for: .normal)
            button.backgroundColor = .clear
            button.addTarget(self, action: #selector(categoryTapped(_:)), for: .touchUpInside)

            stack.addArrangedSubview(button)
            buttons.append(button)
        }
        updateSelection()
    }

    private func updateSelection() {
        for button in buttons {
            let isSelected = (button.title(for: .normal) == selectedCategory)
            if isSelected {
                button.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.15)
                button.setTitleColor(.systemBlue, for: .normal)
                button.layer.borderColor = UIColor.systemBlue.cgColor
            } else {
                button.backgroundColor = .clear
                button.setTitleColor(.label, for: .normal)
                button.layer.borderColor = UIColor.systemGray4.cgColor
            }
        }
    }

    @objc private func categoryTapped(_ sender: UIButton) {
        guard let title = sender.title(for: .normal) else { return }
        selectedCategory = title
        onSelectCategory?(title)
    }
}
