import SwiftUI
import ClockKit

struct ComplicationCircularView: View {
    let counter: Int
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color("AccentColor"))
            Text("\(counter)")
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
                .minimumScaleFactor(0.6)
        }
    }
} 