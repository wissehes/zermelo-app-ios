//
//  API.swift
//  Rooster voor Zermelo
//
//  Created by Wisse Hes on 05/09/2022.
//

import Foundation
import Alamofire

final class API {
    
    static let DEMO_BASEURL = "http://localhost:3000";
    
    static func getWeek(_ date: Date?) -> String {
        
        let components = Calendar.current.dateComponents([.year, .weekOfYear], from: date ?? Date())
        
        if let year = components.year, let week = components.weekOfYear {
            return String(describing: year) + String(format: "%02d", week)
        } else {
            return ""
        }
    }
    
    static func getLiveSchedule(me: ZermeloMeData, completion: @escaping (Result<[ZermeloLivescheduleAppointment], AFError>) -> Void) {
        guard let token = TokenSaver.get() else { return completion(.success([])) }
        
        let params: Parameters = [
            "student": me.code,
            "week": getWeek(nil)
        ]
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token.access_token)"
        ]
        
        AF.request("https://\(token.portal).zportal.nl/api/v3/liveschedule", parameters: params, headers: headers)
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
    
    static func getLiveScheduleAsync(me: ZermeloMeData, week: String = getWeek(nil)) async throws -> [ZermeloLivescheduleAppointment] {
        guard let token = TokenSaver.get() else { fatalError("No token") }
        
        guard var url = URLComponents(string: "https://\(token.portal).zportal.nl/api/v3/liveschedule") else { fatalError("url error") }
        url.queryItems = [
            URLQueryItem(name: "student", value: me.code),
            URLQueryItem(name: "week", value: week)
        ]
        
        var urlRequest = URLRequest(url: url.url!)
        urlRequest.addValue("Bearer \(token.access_token)", forHTTPHeaderField: "Authorization")
        
        let (data, _) = try await URLSession.shared.data(for: urlRequest)
        
        let decoded = try JSONDecoder().decode(GetZermeloLiveschedule.self, from: data)
        if let data = decoded.response.data.first {
            return data.appointments
        } else { return [] }
    }
    
    static func getScheduleForDay(me: ZermeloMeData, date: Date) async throws -> [ZermeloLivescheduleAppointment] {
        let weekAppointments = try await self.getLiveScheduleAsync(me: me, week: getWeek(date))
        
        if weekAppointments.isEmpty {
            return []
        }
        
        let filtered = weekAppointments.filter { app in
            let appointmentDate = Date(timeIntervalSince1970: TimeInterval(app.start))
            return Calendar.current.isDate(appointmentDate, equalTo: date, toGranularity: .day)
        }
        
        return filtered
    }

}
