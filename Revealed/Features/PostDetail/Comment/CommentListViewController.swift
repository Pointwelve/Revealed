//
//  CommentListViewController.swift
//  Revealed
//
//  Created by KokHong on 10/5/20.
//  Copyright © 2020 Pointwelve. All rights reserved.
//

import Foundation
import SwiftUI
import Combine
import CombineDataSources

struct CommentListViewControllerRepresentable: UIViewControllerRepresentable {
  let commentList: PassthroughSubject<[CommentDetail], Never>
  
  func makeUIViewController(context: Context) -> UITableViewController {
    CommentListViewController(commentList: commentList)
  }
  
  func updateUIViewController(_ uiViewController: UITableViewController, context: Context) {
    
  }
  
  typealias UIViewControllerType = UITableViewController
}

private class CommentListViewController: UITableViewController {
  private var disposables = Set<AnyCancellable>()
  
  private let _commentList: PassthroughSubject<[CommentDetail], Never>
  
  init(commentList: PassthroughSubject<[CommentDetail], Never>) {
    _commentList = commentList
    super.init(style: .plain)
    layout()
    bind()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func layout() {
    tableView.register(CommentListTableViewCell.self, forCellReuseIdentifier: CommentListTableViewCell.identifier)
  }
  
  func bind() {
    _commentList
    .bind(subscriber: tableView.rowsSubscriber(cellIdentifier: CommentListTableViewCell.identifier,
                                               cellType: CommentListTableViewCell.self,
                                               cellConfig: { cell, _, model in
        cell.bind(comment: model)
    }))
    .store(in: &disposables)
  }
  
  deinit {
    disposables.removeAll()
  }
}

struct CommentListViewController_Previews: PreviewProvider {
  static var previews: some View {
    /*@START_MENU_TOKEN@*/Text("Hello, World!")/*@END_MENU_TOKEN@*/
  }
}