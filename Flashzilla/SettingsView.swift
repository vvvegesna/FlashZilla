//
//  SettingsView.swift
//  Flashzilla
//
//  Created by Vegesna, Vijay V EX1 on 10/17/20.
//

import SwiftUI

struct SettingsView: View {
   @Environment(\.presentationMode) var presentationMode
    @Binding var isDeleteOff: Bool
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    Toggle(isOn: $isDeleteOff, label: {
                        Text("Delete Off")
                    })
                }
            }
            .listStyle(GroupedListStyle())
            .navigationBarItems(trailing: Button("Done", action: {
                presentationMode.wrappedValue.dismiss()
            }))
            .navigationTitle("Settings")
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(isDeleteOff: .constant(false))
    }
}
