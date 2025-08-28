import SwiftUI

struct SwigglyPathAnimation: View {
    @State private var animationProgress: CGFloat = 0
    
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let width = geometry.size.width
                let height = geometry.size.height
                
                // Use original Lottie proportions (330x80) scaled to fit the available space
                let scaleX = width / 330.0
                let scaleY = height / 80.0
                let scale = min(scaleX, scaleY) // Maintain aspect ratio
                
                // Create path using exact Lottie data with proper bezier curves
                let pathData = createExactLottiePath(scale: scale, width: width, height: height)
                
                path.move(to: pathData.startPoint)
                
                // Add each bezier curve segment from the Lottie data
                for segment in pathData.segments {
                    path.addCurve(
                        to: segment.endPoint,
                        control1: segment.control1,
                        control2: segment.control2
                    )
                }
            }
            .trim(from: 0, to: animationProgress)
            .stroke(Color.green, lineWidth: 4)
            .animation(
                .linear(duration: 2.0)
                .repeatForever(autoreverses: false),
                value: animationProgress
            )
        }
        .onAppear {
            animationProgress = 1.0
        }
    }
    
    // Structure to hold bezier curve segments
    private struct BezierSegment {
        let endPoint: CGPoint
        let control1: CGPoint
        let control2: CGPoint
    }
    
    private struct PathData {
        let startPoint: CGPoint
        let segments: [BezierSegment]
    }
    
    private func createExactLottiePath(scale: CGFloat, width: CGFloat, height: CGFloat) -> PathData {
        let centerX = width / 2
        let centerY = height / 2
        
        // Exact coordinates from your Lottie JSON
        let vertices: [(CGFloat, CGFloat)] = [
            (-153.17, 20.736),
            (-107.167, -14.812),
            (-123.198, 28.404),
            (-40.949, -22.13),
            (-58.375, 20.387),
            (13.767, -22.219),
            (1.917, 22.827),
            (73.013, -16.555),
            (75.104, 25.266),
            (136.974, -17.473),
            (132.957, 17.251),
            (153.17, 6.796)
        ]
        
        // Control point offsets from your Lottie JSON
        let inTangents: [(CGFloat, CGFloat)] = [
            (0, 0),
            (-16.379, 2.44),
            (-12.895, 5.228),
            (-11.85, 2.091),
            (-3.485, -9.06),
            (-12.198, 3.396),
            (-19.516, 2.091),
            (-5.925, -17.077),
            (-19.864, 7.319),
            (-4.42, -5.766),
            (-17.425, 7.667),
            (-3.642, 2.842)
        ]
        
        let outTangents: [(CGFloat, CGFloat)] = [
            (0, 0),
            (16.38, -2.439),
            (12.895, -5.229),
            (11.849, -2.092),
            (3.485, 9.062),
            (12.197, -3.397),
            (19.517, -2.092),
            (5.925, 17.077),
            (19.865, -7.319),
            (4.421, 5.765),
            (17.425, -7.668),
            (0, 0)
        ]
        
        // Convert to scaled points
        let scaledVertices = vertices.map { (x, y) in
            CGPoint(
                x: centerX + (x * scale),
                y: centerY + (y * scale)
            )
        }
        
        let scaledInTangents = inTangents.map { (x, y) in
            CGPoint(x: x * scale, y: y * scale)
        }
        
        let scaledOutTangents = outTangents.map { (x, y) in
            CGPoint(x: x * scale, y: y * scale)
        }
        
        // Create bezier segments
        var segments: [BezierSegment] = []
        
        for i in 1..<scaledVertices.count {
            let currentVertex = scaledVertices[i]
            let previousVertex = scaledVertices[i-1]
            
            // Calculate control points based on Lottie data
            let control1 = CGPoint(
                x: previousVertex.x + scaledOutTangents[i-1].x,
                y: previousVertex.y + scaledOutTangents[i-1].y
            )
            
            let control2 = CGPoint(
                x: currentVertex.x + scaledInTangents[i].x,
                y: currentVertex.y + scaledInTangents[i].y
            )
            
            segments.append(BezierSegment(
                endPoint: currentVertex,
                control1: control1,
                control2: control2
            ))
        }
        
        return PathData(
            startPoint: scaledVertices[0],
            segments: segments
        )
    }
}

#Preview {
    SwigglyPathAnimation()
        .frame(width: 280, height: 20)
        .background(Color.gray.opacity(0.1))
}
