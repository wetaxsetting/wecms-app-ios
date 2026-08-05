//
//  DropdownView.swift
//  WABOOKS_iOS_V2
//
//  Created by SteveChea  on 14/1/25.
//

import UIKit

class DropdownView: UIView {
    private let dropdownMenu: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor(hexString: "#ECEFF1").cgColor
        view.layer.cornerRadius = 5
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.isScrollEnabled = true
        tableView.layer.cornerRadius = 5
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    var heightForRow : Int = 0
    private var dropdownHeightConstraint: NSLayoutConstraint!
    private var isDropdownVisible = false
    private var items: [Items] = []
    var onSelect: ((Items, Bool) -> Void)?
    
    init(items: [Items], heightForRow: Int, isDropdownVisible: Bool) {
        self.items = items
        self.heightForRow = heightForRow
        self.isDropdownVisible = isDropdownVisible
        super.init(frame: .zero)
        setupView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(ItemsCell.self, forCellReuseIdentifier: "ItemsCell")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        addSubview(dropdownMenu)
        dropdownMenu.addSubview(tableView)
        tableView.separatorStyle = .none
        tableView.register(ItemsCell.self, forCellReuseIdentifier: "ItemsCell")
        
        // Shadow settings
        dropdownMenu.layer.masksToBounds = false
        dropdownMenu.layer.shadowColor = UIColor.black.cgColor
        dropdownMenu.layer.shadowOpacity = 0.2 // Adjust opacity for visibility
        dropdownMenu.layer.shadowOffset = CGSize(width: 3, height: 3) // Shadow on left (-3) and bottom (3)
        dropdownMenu.layer.shadowRadius = 5 // Adjust for a smoother shadow
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: dropdownMenu.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: dropdownMenu.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: dropdownMenu.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: dropdownMenu.bottomAnchor),
            
            dropdownMenu.topAnchor.constraint(equalTo: topAnchor),
            dropdownMenu.leadingAnchor.constraint(equalTo: leadingAnchor),
            dropdownMenu.trailingAnchor.constraint(equalTo: trailingAnchor),
            dropdownMenu.heightAnchor.constraint(equalToConstant: CGFloat(heightForRow * items.count)),
        ])
        
        dropdownHeightConstraint = dropdownMenu.heightAnchor.constraint(equalToConstant: 0)
        dropdownHeightConstraint.isActive = true
    }
    
    func toggleDropdown() {
        self.isDropdownVisible.toggle()
        animateDropdown()
    }
    
    private func animateDropdown() {
        let targetHeight = self.isDropdownVisible ? CGFloat(heightForRow * items.count) : 0
          dropdownHeightConstraint.constant = targetHeight
          
          UIView.animate(
              withDuration: 0.5,
              delay: 0,
              usingSpringWithDamping: 0.8,
              initialSpringVelocity: 0.5,
              options: .transitionFlipFromBottom,
              animations: {
                  self.layoutIfNeeded()
              }
          )
      }
}

extension DropdownView: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ItemsCell") as? ItemsCell else { return UITableViewCell() }
        cell.configCell(items[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItem = items[indexPath.row]
        onSelect?(selectedItem, false)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(heightForRow)
    }
}

