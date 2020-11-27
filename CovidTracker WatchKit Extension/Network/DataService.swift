//
//  DataService.swift
//  CovidTracker WatchKit Extension
//
//  Created by Bradley Bernard on 9/23/20.
//

import Foundation
import Combine
import os

enum Endpoint {
    static let identifierKey = "identifier"

    case USToday
    case stateDetail(USAState: USAState)

    var path: String {
        switch self {
            case .USToday:
                return "/v1/us/daily.json"
            case .stateDetail(let USAState):
                let stateAbbreviation = USAState.rawValue.lowercased()
                return "/v1/states/\(stateAbbreviation)/daily.json"
        }
    }

    var identifier: String {
        switch self {
            case .USToday:
                return "USToday"
            case .stateDetail:
                return "StateDetail"
        }
    }
}

enum DataService {
    private static let identifier = "DataService"


    private static let defaultURLSession: URLSession = {
        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration)
        return session
    }()

    private static let queue = DispatchQueue(label: .makeIdentifier(name: Self.identifier))

    private static let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom({ decoder -> Date in
            let container = try decoder.singleValueContainer()
            let dateString: String

            do {
                let dateInteger = try container.decode(Int.self)
                dateString = String(dateInteger)
            } catch {
                dateString = try container.decode(String.self)
            }

            var date: Date?

            // Custom date format from API: "YYYYMMdd"
            if dateString.count == 8 {
                date = CommonDateFormatters.APIDateFormat.date(from: dateString)
            } else {
                date = CommonDateFormatters.ISO6801.date(from: dateString)
            }

            guard let unwrappedDate = date else {
                throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid date string \(dateString)")
            }

            return unwrappedDate
        })

        return decoder
    }()

    private static func url(for endpoint: Endpoint, isBackgroundTask: Bool = false) -> URL? {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "api.covidtracking.com"
        urlComponents.path = endpoint.path

        if isBackgroundTask {
            urlComponents.queryItems = [URLQueryItem(name: Endpoint.identifierKey, value: endpoint.identifier)]
        }

        if let urlString = urlComponents.url?.absoluteString {
            os_log("URL: \(urlString)")
        }

        return urlComponents.url
    }

    static func makeBackgroundURLSession(delegate: URLSessionDelegate) -> URLSession {
        let configuration = URLSessionConfiguration.background(withIdentifier: .makeIdentifier(name: Self.identifier))
        configuration.sessionSendsLaunchEvents = true
        return URLSession(configuration: configuration, delegate: delegate, delegateQueue: nil)
    }

    static func backgroundFetchDailyUS(backgroundURLSession: URLSession) {
        guard let url = Self.url(for: .USToday, isBackgroundTask: true) else {
            return
        }

        let backgroundTask = backgroundURLSession.downloadTask(with: url)
        backgroundTask.countOfBytesClientExpectsToSend = 200 // 200 B
        backgroundTask.countOfBytesClientExpectsToReceive = 177 * 1024 // 177 KB

        os_log("Firing background task: \(String(describing: backgroundTask.currentRequest?.url))")
        backgroundTask.resume()
    }

    static func fetchDailyUS() -> AnyPublisher<[CovidCountry], Error>? {
        guard let url = Self.url(for: .USToday) else {
            return nil
        }

        return defaultURLSession.dataTaskPublisher(for: url)
            .receive(on: self.queue)
            .map(\.data)
            .decode(type: [CovidCountry].self, decoder: Self.decoder)
            .eraseToAnyPublisher()

        //        #if DEBUG
        //        let publisher = PassthroughSubject<Data, Never>()
        //
        //        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
        //            publisher.send(Data(MockData.usDaily.utf8))
        //        }
        //
        //        return publisher
        //            .receive(on: self.queue)
        //            .decode(type: [CovidCountry].self, decoder: Self.decoder)
        //            .eraseToAnyPublisher()
        //        #endif
    }

    static func decodeDailyUS(data: Data) -> [CovidCountry]? {
        return try? Self.decoder.decode([CovidCountry].self, from: data)
    }

    static func fetchHistoricalState(for USAState: USAState) -> AnyPublisher<[CovidState], Error>? {
        guard let url = Self.url(for: .stateDetail(USAState: USAState)) else {
            return nil
        }

        return defaultURLSession.dataTaskPublisher(for: url)
            .receive(on: self.queue)
            .map(\.data)
            .decode(type: [CovidState].self, decoder: Self.decoder)
            .eraseToAnyPublisher()

        //        #if DEBUG
        //        let publisher = PassthroughSubject<Data, Never>()
        //
        //        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
        //            publisher.send(Data(MockData.caDaily.utf8))
        //        }
        //
        //        return publisher
        //            .receive(on: self.queue)
        //            .decode(type: [CovidState].self, decoder: Self.decoder)
        //            .eraseToAnyPublisher()
        //        #endif
    }

    static func backgroundFetchHistoricalState(for USAState: USAState, backgroundURLSession: URLSession) {
        guard let url = Self.url(for: .stateDetail(USAState: USAState), isBackgroundTask: true) else {
            return
        }

        let backgroundTask = backgroundURLSession.downloadTask(with: url)
        backgroundTask.countOfBytesClientExpectsToSend = 200 // 200 B
        backgroundTask.countOfBytesClientExpectsToReceive = 200 * 1024 // 200 KB

        os_log("Firing background task: \(String(describing: backgroundTask.currentRequest?.url))")
        backgroundTask.resume()
    }

    static func decodeHistoricalState(data: Data) -> [CovidState]? {
        return try? Self.decoder.decode([CovidState].self, from: data)
    }
}
