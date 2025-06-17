//
//  OpenSourceListViewController.swift
//  Routory
//
//  Created by shinyoungkim on 6/17/25.
//

import UIKit
import SnapKit
import Then

struct OpenSourceLibrary: Decodable {
    let name: String
    let copyright: String
    let license: String
    let url: String
}

struct OpenSourceData: Decodable {
    let libraries: [OpenSourceLibrary]
    let licenses: [String: LicenseContent]
}

enum LicenseContent: Decodable {
    case string(String)
    case lines([String])

    var fullText: String {
        switch self {
        case .string(let text): return text
        case .lines(let lines): return lines.joined(separator: "\n")
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let text = try? container.decode(String.self) {
            self = .string(text)
        } else if let lines = try? container.decode([String].self) {
            self = .lines(lines)
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid license format")
        }
    }
}

final class OpenSourceViewController: UIViewController {

    // MARK: - Properties
    
    private var libraries: [OpenSourceLibrary] = []
    private var licenses: [String: LicenseContent] = [:]

    // MARK: - UI Components
    
    private let navigationBar = MyPageNavigationBar(title: "오픈소스 라이센스")
    
    private let scrollView = UIScrollView()
    private let contentStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 24
        $0.alignment = .fill
    }

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
        loadData()
    }
    
    func loadData() {
        guard let url = Bundle.main.url(forResource: "opensource_license", withExtension: "json") else {
            print("JSON 파일을 찾을 수 없습니다.")
            return
        }

        do {
            let data = try Data(contentsOf: url)
            let decoded = try JSONDecoder().decode(OpenSourceData.self, from: data)
            self.libraries = decoded.libraries
            self.licenses = decoded.licenses
            render()
        } catch {
            print("디코딩 실패:", error)
        }
    }
}

private extension OpenSourceViewController {
    // MARK: - configure
    func configure() {
        setHierarchy()
        setStyles()
        setConstraints()
        setActions()
    }
    
    // MARK: - setHierarchy
    func setHierarchy() {
        view.addSubviews(
            navigationBar,
            scrollView
        )
        scrollView.addSubview(contentStackView)
    }
    
    // MARK: - setStyles
    func setStyles() {
        view.backgroundColor = .white
    }
    
    // MARK: - setConstraints
    func setConstraints() {
        navigationBar.snp.makeConstraints {
            $0.top.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
            $0.height.equalTo(50)
        }

        scrollView.snp.makeConstraints {
            $0.top.equalTo(navigationBar.snp.bottom)
            $0.bottom.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
        }

        contentStackView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(20)
            $0.width.equalTo(scrollView.snp.width).offset(-40)
        }
    }
    
    // MARK: - setActions
    func setActions() {
        navigationBar.backButtonView.addTarget(
            self,
            action: #selector(backButtonDidTap),
            for: .touchUpInside
        )
    }
    
    @objc func backButtonDidTap() {
        navigationController?.popViewController(animated: true)
    }

    func render() {
        for lib in libraries {
            let label = UILabel().then {
                $0.text = """
                \(lib.name)
                \(lib.copyright)
                \(lib.license)
                \(lib.url)
                """
                $0.font = .bodyMedium(12)
                $0.setLineSpacing(.bodyMedium)
                $0.textColor = .gray900
                $0.numberOfLines = 0
            }
            contentStackView.addArrangedSubview(label)
        }

        if !licenses.isEmpty {
            let divider = UIView().then {
                $0.backgroundColor = .separator
            }
            divider.snp.makeConstraints { $0.height.equalTo(1) }
            contentStackView.addArrangedSubview(divider)
        }

        for (licenseName, content) in licenses {
            let titleLabel = UILabel().then {
                $0.text = "\(licenseName)"
                $0.font = .bodyMedium(14)
                $0.setLineSpacing(.bodyMedium)
                $0.textColor = .gray900
            }

            let bodyLabel = UILabel().then {
                $0.text = content.fullText
                $0.font = .bodyMedium(12)
                $0.setLineSpacing(.bodyMedium)
                $0.textColor = .gray900
                $0.numberOfLines = 0
            }

            contentStackView.addArrangedSubview(titleLabel)
            contentStackView.addArrangedSubview(bodyLabel)
        }
    }
}
