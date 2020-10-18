//
//  ContentView.swift
//  Flashzilla
//
//  Created by Vegesna, Vijay V EX1 on 10/5/20.
//

import SwiftUI

extension View {
    func stacked(at position: Int, in total: Int) -> some View {
        let offset = CGFloat(total - position)
        return self.offset(CGSize(width: 0, height: offset * 10))
    }
}

struct ContentView: View {
    @Environment(\.accessibilityDifferentiateWithoutColor) var differentiateWithoutColor
    @Environment(\.accessibilityEnabled) var accessibilityEnabled
    
    //@State private var showingEditScreen = false
    @State private var cards = [Card]()
    @State private var timeRemaining = 20
    @State private var isActive = true
    @State private var isDeleteOff = false
    //@State private var isShowingSetting = false
    @State private var currentSheet: SheetType?
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    enum SheetType: String, Identifiable {
        var id: String {
            rawValue
        }
        case settings, addCard
    }
    
    var body: some View {
        let settingsValue = Binding(
                            get: { isDeleteOff },
                            set: {
                                isDeleteOff = $0
                            })
        return ZStack {
            Image(decorative: "background")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
            VStack {
                if timeRemaining > 0 {
                    Text("Time: \(timeRemaining)")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 5)
                        .background(Capsule().opacity(0.75))
                } else {
                    Text("Out of time")
                        .font(.largeTitle)
                        .foregroundColor(.red)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 5)
                        .background(Capsule())
                }
                ZStack {
                    ForEach(0..<cards.count, id:\.self) { index in
                        CardView(card: cards[index]) {
                            withAnimation {
                                deleteCard(at: index)
                            }
                        }
                        .stacked(at: index, in: cards.count)
                        .allowsHitTesting(index == cards.count - 1)
                        .accessibility(hidden: index < cards.count - 1)
                    }
                }
                .allowsHitTesting(timeRemaining > 0)
                if cards.isEmpty {
                    Button("Reset", action: resetCards)
                        .padding()
                        .background(Color.white)
                        .foregroundColor(.black)
                        .clipShape(Capsule())
                }
            }
            VStack {
                HStack {
                    Button(action: { currentSheet = .settings }) {
                    Image(systemName: "gear")
                        .padding()
                        .font(.largeTitle)
                        .background(Color.black.opacity(0.75))
                        .foregroundColor(.white)
                        .clipShape(Circle())
                    }
                    Spacer()
                    Button(action: {
                        currentSheet = .addCard
                    }) {
                        Image(systemName: "plus.circle")
                            .padding()
                            .background(Color.black.opacity(0.7))
                            .clipShape(Circle())
                    }
                }
                Spacer()
            }
            .foregroundColor(.white)
            .font(.largeTitle)
            .padding()
            if differentiateWithoutColor || accessibilityEnabled {
                VStack {
                    Spacer()
                    HStack {
                        Button(action: {
                            withAnimation {
                                self.deleteCard(at: self.cards.count - 1)
                            }
                        }) {
                            Image(systemName: "xmark.circle")
                                .padding()
                                .background(Color.black.opacity(0.7))
                                .clipShape(Circle())
                        }
                        .accessibility(label: Text("Wrong"))
                        .accessibility(hint: Text("Mark your answer as being incorrect."))
                        Spacer()
                        
                        Button(action: {
                            withAnimation {
                                self.deleteCard(at: self.cards.count - 1)
                            }
                        }) {
                            Image(systemName: "checkmark.circle")
                                .padding()
                                .background(Color.black.opacity(0.7))
                                .clipShape(Circle())
                        }
                        .accessibility(label: Text("Correct"))
                        .accessibility(hint: Text("Mark your answer as being correct."))
                    }
                    .foregroundColor(.white)
                    .font(.largeTitle)
                    .padding()
                }
            }
        }
        .onReceive(timer, perform: { _ in
            guard isActive else { return }
            if timeRemaining > 0 {
                timeRemaining -= 1
            }
        })
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification), perform: { _ in
            isActive = false
        })
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification), perform: { _ in
            if !cards.isEmpty {
                isActive = true
            }
        })
        .sheet(item: $currentSheet, content: { sheet in
            if sheet == .settings {
                SettingsView(isDeleteOff: settingsValue)
            } else {
                CardEditView() {
                    currentSheet = .none
                    resetCards()
                }
            }
        })
        .onAppear(perform: resetCards)
    }
    
    func deleteCard(at index: Int) {
        guard index >= 0 else { return }
        
        cards.remove(at: index)
        if cards.isEmpty {
            isActive = false
        }
    }
    
    func resetCards() {
        cards = [Card]()
        isActive = true
        timeRemaining = 20
        loadData()
    }
    
    func loadData() {
        if let data = UserDefaults.standard.data(forKey: "Cards") {
            if let decoded = try? JSONDecoder().decode([Card].self, from: data) {
                self.cards = decoded
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
