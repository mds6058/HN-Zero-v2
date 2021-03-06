//
//  ArticleListViewController.swift
//  Hacker News Zero
//
//  Created by Matt Stanford on 2/4/18.
//  Copyright © 2018 locacha. All rights reserved.
//

import Foundation
import RxSwift

class ArticleListViewModel {
    let pageSize = 25
    var articleViewModels = [ArticleViewModel]()
    private let repository: HackerNewsRepository
    var articleType: ArticleType = .frontpage

    private var numLoadingTasks = 0
    private var currentPageNum = 0
    private var reachedLastPage = false

    var shouldTryToLoadMorePages: Bool {
        return numLoadingTasks == 0 && !reachedLastPage
    }

    init(repository: HackerNewsRepository) {
        self.repository = repository
    }

    func startedLoading() {
        numLoadingTasks += 1
    }

    func finishedLoading() {
        numLoadingTasks -= 1
    }

    func reset() {
        reachedLastPage = false
        articleViewModels = [ArticleViewModel]()
    }

    func refreshArticles() -> Completable {
        currentPageNum = 0

        return repository.refreshArticleList(type: articleType)
            .andThen(self.getPageOfArticles(pageNum: 0))
            .map({ [weak self] articleViewModels in
                self?.articleViewModels = articleViewModels
            })
            .asObservable()
            .ignoreElements()
    }

    func getNextPageOfArticles() -> Completable {
        let nextPage = currentPageNum + 1
        return getPageOfArticles(pageNum: nextPage)
            .asObservable()
            .map({ [weak self] articleViewModels in
                self?.articleViewModels.append(contentsOf: articleViewModels)
            })
            .ignoreElements()
    }

    func getPageOfArticles(pageNum: Int) -> Single<[ArticleViewModel]> {
        return repository.getArticles(for: pageNum, pageSize: pageSize)
            .map { [weak self] articles -> [ArticleViewModel] in

                var viewModels: [ArticleViewModel] = []
                if articles.count > 0 {
                    self?.currentPageNum = pageNum
                } else {
                    self?.reachedLastPage = true
                }

                for article in articles {
                    let viewModel = ArticleViewModel(article: article)
                    viewModels.append(viewModel)

                }

                return viewModels
            }
    }
}
