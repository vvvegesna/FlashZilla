//
//  CardView.swift
//  Flashzilla
//
//  Created by Vegesna, Vijay V EX1 on 10/11/20.
//

import SwiftUI

struct CardView: View {
    @Environment(\.accessibilityDifferentiateWithoutColor) var differentiateWithoutColor
    @Environment(\.accessibilityEnabled) var accessibilityEnabled
    
    let card: Card
    var removal: (() -> Void)? = nil
    
    @State private var showingAnswer = false
    @State private var dragOffset = CGSize.zero
    @State private var feedback = UINotificationFeedbackGenerator()
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25, style: .continuous)
                .fill(
                    differentiateWithoutColor
                        ? Color.white
                        : Color.white
                            .opacity(1 - Double(abs(dragOffset.width) / 50))
                )
                .background(
                    differentiateWithoutColor
                        ? nil
                        : RoundedRectangle(cornerRadius: 25, style: .continuous)
                            .fill(dragOffset.width >= 0 ? Color.green : Color.red)
                )
                .shadow(radius: 10)
            VStack {
                if accessibilityEnabled {
                    Text(showingAnswer ? card.answer : card.prompt)
                        .font(.largeTitle)
                        .foregroundColor(.black)
                } else {
                    Text(card.prompt)
                        .font(.largeTitle)
                        .foregroundColor(.black)

                    if showingAnswer {
                        Text(card.answer)
                            .font(.title)
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(20)
            .multilineTextAlignment(.center)
        }
        .frame(width: 450, height: 250)
        .rotationEffect(.degrees(Double(dragOffset.width/5)))
        .offset(x: dragOffset.width * 5, y: 0)
        .opacity(2 - Double(abs(dragOffset.width) / 50))
        .accessibility(addTraits: .isButton)
        .gesture(DragGesture()
                    .onChanged { (gesture) in
                        dragOffset = gesture.translation
                        feedback.prepare()
                    }
                    .onEnded { _ in
                        if abs(dragOffset.width) > 100 {
                            if dragOffset.width > 0 {
                                feedback.notificationOccurred(.success)
                            } else {
                                feedback.notificationOccurred(.error)
                            }
                            removal?()
                        } else {
                            dragOffset = .zero
                        }
                    }
        )
        .onTapGesture{
            showingAnswer.toggle()
        }
        .animation(.spring())
    }
}

struct CardView_Previews: PreviewProvider {
    static var previews: some View {
        CardView(card: Card.example)
    }
}
