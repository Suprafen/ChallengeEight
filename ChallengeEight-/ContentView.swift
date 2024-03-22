//
//  ContentView.swift
//  ChallengeEight-
//
//  Created by Ivan Pryhara on 20/03/2024.
//

import SwiftUI

struct ContentView: View {
    @State private var progress: Double = .zero
    @State private var offset: Double = .zero
    @State private var lastOffset: Double = .zero
    
    @State private var counter: Int = 0
    
    @State private var isSliderEaten: Bool = false
    
    @State private var isWormVisible: Bool = false
    @State private var wormScale: Double = 0
    @State private var title: String = "А М Б Р О З И Я"
    @State private var isTitleVisible: Bool = false
    
    private let cornerRadius: Double = 25
    private let maxHeight: Double = 180
    private let maxWidth: Double = 90
    
    private var progressValue: Double {
        max(progress, .zero) * maxHeight
    }
    
    private var sliderBackground: some View {
        Rectangle()
            .background(.ultraThinMaterial)
    }
    
    private var sliderDragable: some View {
        Rectangle()
            .foregroundStyle(.black.opacity(0.8))
            .frame(height: progressValue)
    }
    
    private var gradient: some View {
        LinearGradient(colors: [.yellow, .yellow, .orange,],
                       startPoint: .bottomLeading,
                       endPoint: .bottom)
        .ignoresSafeArea()
    }
    
    private var slider: some View {
        ZStack(alignment: .bottom) {
            sliderBackground
            sliderDragable
        }
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        .contentShape(RoundedRectangle(cornerRadius: cornerRadius))
        .frame(width: maxWidth,
               height:  progress < 0 ? maxHeight + (-progress * maxHeight) : maxHeight,
               alignment: progress < 0 ? .top : .bottom)
        .gesture(
            DragGesture(minimumDistance: 0)
            .onChanged {
                let translation = $0.translation
                withAnimation(.easeIn(duration: 0.3)) {
                    let movement = -translation.height + lastOffset
                    
                    offset = movement
                    calculateProgress()
                }
            }
            .onEnded { _ in
                withAnimation(.easeIn(duration: 0.3)) {
                    offset = offset > maxHeight ? maxHeight : (offset < 0 ? 0 : offset)
                    calculateProgress()
                }
                
                lastOffset = offset
            }
        )
        .frame(width: maxWidth,
               height:  maxHeight,
               alignment: progress < 0 ? .top : .bottom)
        .padding()
    }
    
    var body: some View {
        if isTitleVisible {
            Text(title)
                .font(.title)
                .bold()
                .foregroundStyle(.black)
                .transition(.scale)
        }
        ZStack {
            gradient
            if isWormVisible {
                WormView(foregroundColor: .constant(.brown))
                    .opacity(0.4)
                    .transition(.scale.combined(with: .opacity))
                    .onAppear(perform: {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            withAnimation {
                                wormScale = 1
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                withAnimation(.easeOut(duration: 4)) {
                                    isSliderEaten = true
                                } completion: {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                                        withAnimation(.smooth(duration: 10)) {
                                            isTitleVisible = true
                                            counter = 0
                                            wormScale = 0
                                        } completion: {
                                            withAnimation(.smooth(duration: 10)) {
                                                isWormVisible = false
                                                isSliderEaten = false
                                                isTitleVisible = false
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    })
                    .scaleEffect(wormScale != 0 ? wormScale : 0)
            }
                slider
                    .scaleEffect(isSliderEaten ? 0 : 1)
                    .onChange(of: counter) { oldValue, newValue in
                        if newValue == 3 {
                            isWormVisible.toggle()
                        }
                    }
        }
        .ignoresSafeArea()
    }
    
    private func calculateProgress() {
        let strength: Double = 0.05
        
        let topExcessOffset = maxHeight + (offset - maxHeight) * strength
        let bottomExcessOffset = offset < 0 ? (offset * strength) : offset
        
        if offset > maxHeight {
            withAnimation(.easeInOut(duration: 4)) {
                counter += 1
            }
        }
        
        let progress = (offset > maxHeight ? topExcessOffset : bottomExcessOffset) / maxHeight
        
        self.progress = progress > 1.1 ? 1.05 : progress
    }
}

struct WormView: View {
    @Binding var foregroundColor: Color
    
    let borderWidth: CGFloat = 20
    
    @State private var now: Date = Date.now
    
    var body: some View {
        GeometryReader { geometry in
            let radius = geometry.size.width / 2
            let innerRadius = radius - borderWidth
            
            let centerX = geometry.size.width / 2
            let centerY = geometry.size.height / 2
            
            let center = CGPoint(x: centerX, y: centerY)
            
            Circle()
                .foregroundColor(foregroundColor)
            
            Circle()
                .foregroundColor(.gray.opacity(0.4))
            
            Circle()
                .foregroundColor(.black.opacity(0.7))
                .frame(width: 200, height: 200)
                .padding(borderWidth)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            Circle()
                .foregroundColor(.black.opacity(0.7))
                .padding(borderWidth)
            

            TimelineView(.animation) { tl in
                let time = now.distance(to: tl.date)
                
            Path { path in
                for index in 0..<60 {
                    let radian = Angle(degrees: Double(index) * 6 - 90).radians
                    
                    let height = (radius * sin(time / 3))
                    
                    let lineHeight: Double = height <= 20 ? 20 : height >= 120 ? 120 : height
                    
                    let x1 = centerX + innerRadius * cos(radian)
                    let y1 = centerY + innerRadius * sin(radian)
                    
                    let x2 = centerX + (innerRadius - lineHeight) * cos(radian)
                    let y2 = centerY + (innerRadius - lineHeight) * sin(radian)
                    
                    path.move(to: .init(x: x1, y: y1))
                    path.addLine(to: .init(x: x2, y: y2))
                }
            }
            .stroke(style: StrokeStyle(lineWidth: 1, lineCap: .round))
            .foregroundColor(.black)
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

#Preview {
    ContentView()
}
