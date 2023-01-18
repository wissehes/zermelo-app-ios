//
//  API.swift
//  Rooster voor Zermelo
//
//  Created by Wisse Hes on 05/09/2022.
//

import Foundation
import Alamofire

final class API {
    
    static let DEMO_BASEURL = "https://demo.wissehes.nl";
    
    static func getWeek(_ date: Date?) -> String {
        
        let components = Calendar.current.dateComponents([.year, .weekOfYear], from: date ?? Date())
        
        if let year = components.year, let week = components.weekOfYear {
            return String(describing: year) + String(format: "%02d", week)
        } else {
            return ""
        }
    }
    
    static func getLiveSchedule(completion: @escaping (Result<[ZermeloLivescheduleAppointment], AFError>) -> Void) {
        guard let user = UserManager.getCurrent() else { return completion(.success([])) }
        
        let params: Parameters = [
            "student": user.me.code,
            "week": getWeek(nil)
        ]
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(user.token.access_token)"
        ]
        
        AF.request("https://\(user.token.portal).zportal.nl/api/v3/liveschedule", parameters: params, headers: headers)
            .validate()
            .responseDecodable(of: GetZermeloLiveschedule.self) { response in
                switch response.result {
                case .success(let _data):
                    guard let data = _data.response.data.first else { return completion(.success([])) }
                    
                    completion(.success(data.appointments))
                case .failure(let err):
                    completion(.failure(err))
                }
            }
    }
    
    static func getLiveScheduleAsync(week: String = getWeek(nil)) async throws -> [ZermeloLivescheduleAppointment] {
        guard let user = UserManager.getCurrent() else { fatalError("No token") }
        
        guard var url = URLComponents(string: "https://\(user.token.portal).zportal.nl/api/v3/liveschedule") else { fatalError("url error") }
        url.queryItems = [
            URLQueryItem(name: "student", value: user.me.code),
            URLQueryItem(name: "week", value: week)
        ]
        
        var urlRequest = URLRequest(url: url.url!)
        urlRequest.addValue("Bearer \(user.token.access_token)", forHTTPHeaderField: "Authorization")
        
        let (data, _) = try await URLSession.shared.data(for: urlRequest)
        
        let decoded = try JSONDecoder().decode(GetZermeloLiveschedule.self, from: data)
        if let data = decoded.response.data.first {
            return data.appointments
        } else { return [] }
    }
    
    static func getScheduleForDay(date: Date) async throws -> [ZermeloLivescheduleAppointment] {
        let weekAppointments = try await self.getLiveScheduleAsync(week: getWeek(date))
        
        if weekAppointments.isEmpty {
            return []
        }
        
        let filtered = weekAppointments.filter { app in
            let appointmentDate = Date(timeIntervalSince1970: TimeInterval(app.start))
            return Calendar.current.isDate(appointmentDate, equalTo: date, toGranularity: .day)
        }
        
        return filtered
    }
    
    static func fetchMe(token: SavedToken, completion: @escaping (Result<ZermeloMeData, FetchError>) -> ()) {
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token.access_token)"
        ]
        
        AF.request("https://\(token.portal).zportal.nl/api/v3/users/~me", headers: headers)
            .validate()
            .responseDecodable(of: GetZermeloMe.self) { response in
                switch response.result {
                case .success(let data):
                    guard let me = data.response.data.first else {
                        completion(.failure(.noData))
                        return
                    }
                    completion(.success(me))
                case .failure(let err):
                    completion(.failure(.AFError(error: err)))
                }
            }
    }

}

enum FetchError: Error {
    case noData
    case AFError(error: AFError)
}
