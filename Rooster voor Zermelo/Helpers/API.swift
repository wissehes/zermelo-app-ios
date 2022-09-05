//
//  API.swift
//  Rooster voor Zermelo
//
//  Created by Wisse Hes on 05/09/2022.
//

import Foundation
import Alamofire

final class API {
    static func getLiveSchedule(me: ZermeloMeData, completion: @escaping (Result<[ZermeloLivescheduleAppointment], AFError>) -> Void) {
        
        guard let token = TokenSaver.get() else { return completion(.success([])) }
        
        let params: Parameters = [
            "student": me.code,
            "week": 202236
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
}
