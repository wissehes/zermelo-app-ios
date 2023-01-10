//
//  NewWeekView.swift
//  Rooster voor Zermelo
//
//  Created by Wisse Hes on 17/10/2022.
//

import SwiftUI

struct NewWeekView: View {
    
    let days: [String] = ["Ma", "Di", "Wo", "Do", "Vr"]
    let a = ["GS", "DUTL", "NETL", "WA"]
    let l = ["6s", "10r", "11a", "at1-bov", "18l"]
    
    var body: some View {
        HStack(alignment: .top) {
            ForEach(days, id: \.self) { day in
                VStack(alignment: .center) {
                    Text(day)
                        .fontWeight(.heavy)
                        .foregroundColor(.secondary)
                    
                    ForEach(1...5, id: \.self) { _ in
                        appointment()
                    }
                    
                    Spacer()
                }
            }
        }.navigationTitle("Week")
        //            .padding(0)
    }
    
    func appointment() -> some View {
        VStack(alignment: .leading) {
            Text(a.randomElement()!)
                .fontWeight(.bold)
                .multilineTextAlignment(.leading)
            
            Text(l.randomElement()!)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.leading)
            
        }.frame(width: 70, height: 50)
            .overlay(
                RoundedRectangle(cornerRadius: 2.5)
                    .stroke(lineWidth: 1)
            )
        
    }
}

struct NewWeekView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            NewWeekView()
        }
    }
}
