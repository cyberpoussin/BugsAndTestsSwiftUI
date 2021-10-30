//
//  CustomShape.swift
//  NewProjectApril
//
//  Created by admin on 27/04/2021.
//

import SwiftUI

struct CustomContentView: View {
    var colors: [Color] = [.blue, .red, .green, .orange]
    @State var index: Int = 0
    
    @State var progress: CGFloat = 0
    var body: some View {
        VStack {
            SplashView(animationType: .leftToRight, color: self.colors[self.index])
                .frame(width: 200, height: 100, alignment: .center)
                .cornerRadius(10)
                .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 4)
            
            Button(action: {
                self.index = (self.index + 1) % self.colors.count
            }) {
                Text("Tracer le graph")
            }
            .padding(.top, 20)
        }
  
    }
}

struct CustomShape: View {
    var body: some View {
        SplashView(animationType: .leftToRight, color: .red)
    }
}

struct CustomShape_Previews: PreviewProvider {
    static var previews: some View {
        CustomContentView()
    }
}

struct SplashView: View {
    
    var animationType: SplashShape.SplashAnimation
    @State private var prevColor: Color // Stores background color
    var color: Color // Send new color updates
    @State var layers: [(Color,CGFloat)] = [] // New Color & Progress

    
    init(animationType: SplashShape.SplashAnimation, color: Color) {
        self.animationType = animationType
        self._prevColor = State<Color>(initialValue: color)
        self.color = color
    }

    var body: some View {
        Rectangle()
            .foregroundColor(self.prevColor)
            .overlay(
                ZStack {
                    ForEach(layers.indices, id: \.self) { x in
                        Graphique(progress: self.layers[x].1, animationType: self.animationType)
                            .foregroundColor(self.layers[x].0)
                    }

                }

                , alignment: .leading)
            .onChange(of: self.color) { color in
                // Animate color update here
                self.layers.append((color, 0))

                withAnimation(.linear(duration: 1)) {
                    self.layers[self.layers.count-1].1 = 1.0
                }
            }
    }

}


struct SplashShape: Shape {
    
    public enum SplashAnimation {
        case leftToRight
        case rightToLeft
    }
    
    var progress: CGFloat
    var animationType: SplashAnimation

    var animatableData: CGFloat {
        get { return progress }
        set { self.progress = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
       switch animationType {
           case .leftToRight:
               return leftToRight(rect: rect)
           case .rightToLeft:
               return rightToLeft(rect: rect)
       }
    }
    
    
    
    func leftToRight(rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: 0)) // Top Left
        path.addLine(to: CGPoint(x: rect.width * progress, y: 0)) // Top Right
        path.addLine(to: CGPoint(x: rect.width * progress, y: rect.height)) // Bottom Right
        path.addLine(to: CGPoint(x: 0, y: rect.height)) // Bottom Left
        path.closeSubpath() // Close the Path
        return path
    }

    
    func rightToLeft(rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.width, y: 0))
        path.addLine(to: CGPoint(x: rect.width - (rect.width * progress), y: 0))
        path.addLine(to: CGPoint(x: rect.width - (rect.width * progress), y: rect.height))
        path.addLine(to: CGPoint(x: rect.width, y: rect.height))
        path.closeSubpath()
        return path
    }
}


// Le cours des 20 derniers jours :
let appleCours: [Double] = [121.39, 119.90, 122.15, 123.00, 125.90, 126.21, 127.90, 130.36, 133.00, 131.24, 134.43, 132.03, 134.50, 134.16, 134.84, 133.11, 133.50, 131.94, 134.32, 134.48]

let x0: Double = 10.00
let y0: Double = 10.00

// On va dessiner dans un rectangle de 220 x 110.
// En laissant :
// x0 de marge à gauche et 4 * x0 à droite
// et y0 de marge en haut et en bas.
// Attention, le point (0,0) est en haut à gauche.

var EchelleX: Double {
    return (220.00 - 4.00 * x0) / 20.00
}

var MinY: Double {
    return appleCours.min()!
}

var EchelleY: Double {
    return (110.00 - 2.00 * y0) / (appleCours.max()! - MinY)
}

struct Graphique: Shape {

    
    var progress: CGFloat
    var animationType: SplashShape.SplashAnimation

    var animatableData: CGFloat {
        get { return progress }
        set { self.progress = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
       switch animationType {
           case .leftToRight:
               return leftToRight(rect: rect)
           case .rightToLeft:
            return leftToRight(rect: rect)
       }
    }
    
    func leftToRight(rect: CGRect) -> Path {
        var path = Path()
        
        path.move(to: CGPoint(x: CGFloat(x0), y: CGFloat((110.00 - (appleCours[0] - MinY) * EchelleY) - y0)))

        appleCours.enumerated().filter({CGFloat($0.0) < progress * CGFloat(appleCours.count) }).forEach { indice, cours in
            if (indice != 0 && CGFloat(indice) < progress  * CGFloat(appleCours.count)) { // Pour ne pas redessiner le premier point.
                
                path.addLine(to: CGPoint(x: CGFloat(x0 + Double(indice) * EchelleX), y: CGFloat((110.00 - (cours - MinY) * EchelleY) - y0)))
            }
        } // forEach

        // On ferme le path pour pouvoir le remplir avec un dégradé :
        path.addLine(to: CGPoint(x: CGFloat(x0 + Double(19 * progress) * EchelleX), y: CGFloat(110.00 - x0)))
        path.addLine(to: CGPoint(x: CGFloat(x0), y: CGFloat(110.00 - x0)))
        path.closeSubpath()
        return path
    }
}
