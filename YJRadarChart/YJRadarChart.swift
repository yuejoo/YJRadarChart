//
//  YJRadarChart.swift
//  YJRadarChart
//
//  Created by zhaoye on 10/17/19.
//  Copyright © 2019 zhaoye. All rights reserved.
//

import SwiftUI

struct Polygon: Shape {
    let corners: Int
    let data: [Double]

    func path(in rect: CGRect) -> Path {
        guard corners >= 2 else { return Path() }
        
        let center = CGPoint(x: rect.width / 2, y: rect.height / 2)
        var currentAngle = -CGFloat.pi / 2
        let angleAdjustment = .pi * 2 / CGFloat(corners)

        var path = Path()
        
        let startPoint = CGPoint(x: center.x * cos(currentAngle), y: center.y * sin(currentAngle))
        
        path.move(to: startPoint)

        for corner in 0..<corners  {
            let sinAngle = sin(currentAngle)
            let cosAngle = cos(currentAngle)
            let bottom: CGFloat

            let factor = CGFloat(data[corner])
            
            bottom = center.y * sinAngle * factor

            path.addLine(to: CGPoint(x: factor * center.x * cosAngle, y: bottom))

            currentAngle += angleAdjustment
        }
        
        path.addLine(to: startPoint)

        let transform = CGAffineTransform(translationX: center.x, y: center.y)
        return path.applying(transform)
    }
}

struct InnerLines: Shape {
    let corners: Int

    public static func getCorners(width: CGFloat, height: CGFloat, corners: Int, buffer: Int = 10) -> [CGPoint]{
        var cgpoints : [CGPoint] = []
        var currentAngle = -CGFloat.pi / 2

        let center = CGPoint(x: width / 2, y: height / 2)
        let angleAdjustment = .pi * 2 / CGFloat(corners)
        let newX = center.x.advanced(by: CGFloat(buffer))
        let newY = center.y.advanced(by: CGFloat(buffer))
    
        for _ in 0..<corners  {
            let sinAngle = sin(currentAngle)
            let cosAngle = cos(currentAngle)
            let bottom: CGFloat
            
            bottom = newY * sinAngle
            cgpoints.append(
                CGPoint(x: newX * cosAngle, y: bottom)
            )
            
            currentAngle += angleAdjustment
        }
        
        return cgpoints
    }
    
    func path(in rect: CGRect) -> Path {
        guard corners >= 2 else { return Path() }
        
        let center = CGPoint(x: rect.width / 2, y: rect.height / 2)
        var currentAngle = -CGFloat.pi / 2
        let angleAdjustment = .pi * 2 / CGFloat(corners)
        var path = Path()
        let startPoint = CGPoint(x: CGFloat(0), y: CGFloat(0))

        for _ in 0..<corners  {
            let sinAngle = sin(currentAngle)
            let cosAngle = cos(currentAngle)
            let bottom: CGFloat
            
            bottom = center.y * sinAngle

            path.move(to: startPoint)
            
            path.addLine(to: CGPoint(x: center.x * cosAngle, y: bottom))

            currentAngle += angleAdjustment
        }
        
        let transform = CGAffineTransform(translationX: center.x, y: center.y)
        return path.applying(transform)
    }
}

class ColorProvider {
    var index : Int
    var colors : [Color]
    
    required init(_ colors : [Color]) {
        self.colors = colors
        self.index = 0
    }
    
    private func nextIndex() {
        index = (index == self.colors.count - 1 ? 0 : index + 1)
    }
    
    public func nextColor() -> Color {
        let color = colors[index]
        self.nextIndex()
        return color
    }
}

struct LabelView: View {
    
    var body: some View {
        Text("")
    }
}

struct Board: View {
    @Binding var corners: Int
    
    let numberOfCircles : Int = 5
    let lineWidthFactor : CGFloat = CGFloat(0.3)
    let size : Int = 250
    let accumulatedFactor : Int = 50
    
    var body: some View {
        let points = InnerLines.getCorners(
            width: CGFloat(size),
            height: CGFloat(size),
            corners: corners
        )
    
        return ZStack {
            Image(systemName: "clock").offset(x: points[0].x, y: points[0].y)
    
            
            ForEach((1...numberOfCircles), id:\.self) {
                factor in Circle()
                    .stroke(
                        Color.gray,
                        lineWidth: self.lineWidthFactor
                    )
                    .frame(width: CGFloat(factor*self.accumulatedFactor),
                           height: CGFloat(factor*self.accumulatedFactor)
                )
            }
            InnerLines(corners: corners).stroke(
                Color.gray,
                lineWidth: self.lineWidthFactor
            ).frame(
                width: CGFloat(self.size),
                height: CGFloat(self.size)
            )
        }
    }
}

struct YJRadarChart: View {
    @State var corners : Int = 6
    
    var body: some View {
        ZStack {
            Board(corners: $corners)
            
            Polygon(corners: 5, data: [1,0.3,0.9,1,0.5])
                .fill(Color.green)
                .opacity(0.75)
                .frame(
                    width: CGFloat((5)*50),
                    height: CGFloat((5)*50)
            )
        }
    }

    var colorProvider : ColorProvider = ColorProvider([Color.gray, Color.white])
}

struct Badge_Previews: PreviewProvider {
    static var previews: some View {
        Badge()
    }
}
