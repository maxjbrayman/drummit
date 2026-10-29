//
//  LoadState.swift
//  Drummit
//
//  Created by Max Brayman on 10/16/26.
//

enum LoadState<T> {
    case loading
    case error(String)
    case success(T)
    case idle
}
