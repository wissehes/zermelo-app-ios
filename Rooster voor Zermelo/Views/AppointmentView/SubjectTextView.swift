//
//  SubjectTextView.swift
//  Rooster voor Zermelo
//
//  Created by Wisse Hes on 27/03/2023.
//

import SwiftUI

struct SubjectTextView: View {
    
    var subjects: [String]
    
    let single: LocalizedStringKey = "appointment.subjects.single"
    let multiple: LocalizedStringKey = "appointment.subjects.multiple"
    let icon = "graduationcap"
    
    @State private var fullNames: [String]?
    
    func load() async {
        let fullnames = await SubjectManager.shared.getFullNameAsync(subjects)
        DispatchQueue.main.async {
            withAnimation {
                self.fullNames = fullnames
            }
        }
    }

    var body: some View {
        HStack {
            Label(subjects.count == 1 ? single : multiple, systemImage: icon)
                .fontWeight(.bold)
            Spacer()
            if subjects.isEmpty {
                Text("word.none")
                    .italic()
                    .multilineTextAlignment(.trailing)
            } else {
                Text((fullNames ?? subjects).join(.normal))
                    .font(.system(.body, design: .rounded))
                    .multilineTextAlignment(.trailing)
            }
        }
        .task {
            await load()
        }
    }
}

struct SubjectTextView_Previews: PreviewProvider {
    static var previews: some View {
        SubjectTextView(subjects: ["entl"])
    }
}
