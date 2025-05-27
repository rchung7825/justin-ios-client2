import SwiftUI
import AVFoundation

class ContentViewModel: ObservableObject {
    let pages = [
        ["", "", "", "", "", "", "", ""],
        ["super-simple-songs","coco-melon","little-baby-bum", "bear-in-the-big-blue-house", "mickey-mouse", "super-why", "", ""],
        // Home
        ["eat", "music", "bathroom", "drink", "stop", "toy", "go", "different"],
        ["meal", "snack", "candy", "", "", "", "", ""],
        ["water", "juice", "", "", "", "", "", "" ],
        ["mario-kart", "asphalt-6", "", "", "", "", "", ""],
    ]
    
    // Dictionary mapping page names to system image names
    let imageNames: [String: String] = [
        "eat": "leaf.fill",
        "bathroom": "house.fill",
        "music": "music.note",
        "drink": "drop.fill",
        "different": "circle.fill",
        "stop": "stop.fill",
        "toy": "gamecontroller.fill",
        "go": "arrow.right.circle.fill",
    ]
    
    let synthesizer = AVSpeechSynthesizer()
}

struct ContentView: View {
    @StateObject var contentViewModel = ContentViewModel()
    @State private var currentPage = 2
    @State private var pageNumber = 3
    @State private var audioPlayer: AVAudioPlayer?

    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                NavigationButtons(currentPage: $currentPage, pageNumber: $pageNumber)
                
                Spacer()
                
                PageGrid(pageLabels: contentViewModel.pages[currentPage],
                         shortPressAction: { label in
                             playMP3(for: label)
                         },
                         longPressAction: { label in
                             switchPage(for: label)
                         })
                    .frame(width: geometry.size.width * 0.7)
                    .padding(.leading, 100)
                    .padding(.trailing, 50)
            }
            .padding()
        }
    }
    
    // Function to play MP3
    func playMP3(for label: String) {
        guard !label.isEmpty else { return }
        
        if let previousPlayer = audioPlayer, previousPlayer.isPlaying {
            previousPlayer.stop()
        }
        
        // Debugging print statement to show the path being used
        if let mp3URL = Bundle.main.url(forResource: label, withExtension: "mp3", subdirectory: "mp3") {
            print("Found MP3 file at path: \(mp3URL.path)")
        } else {
            print("MP3 file not found for '\(label)'")
            return
        }
        
        guard let mp3URL = Bundle.main.url(forResource: label, withExtension: "mp3", subdirectory: "mp3") else {
            print("MP3 file not found for '\(label)'")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: mp3URL)
            audioPlayer?.play()
        } catch {
            print("Error playing audio: \(error.localizedDescription)")
        }
    }
    
    // Function to switch pages (placeholder)
    func switchPage(for label: String) {
        // Implement the functionality to switch pages here
        print("Switching page for \(label)")
    }
}

struct NavigationButtons: View {
    @Binding var currentPage: Int
    @Binding var pageNumber: Int
    
    var body: some View {
        VStack(spacing: 10) {
            Button(action: {
                // Implement the functionality to move up
            }) {
                VStack {
                    Spacer()
                    Image(systemName: "arrow.up")
                        .resizable()
                        .frame(width: 60, height: 60)
                        .padding(.bottom)
                    Text("Up")
                        .font(.system(size: 20, weight: .bold))
                    Spacer()
                }
                .frame(minWidth: 150, maxHeight: .infinity)
                .border(Color.black)
            }
            
            Spacer()
            
            Button(action: {
                // Implement the functionality to go to home
            }) {
                Text("Home")
                    .font(.system(size: 20, weight: .bold))
                    .frame(width: 150, height: UIScreen.main.bounds.height * 0.2)
            }
            .border(Color.black)
            
            Spacer()
            
            Button(action: {
                // Implement the functionality to move down
            }) {
                VStack {
                    Spacer()
                    Image(systemName: "arrow.down")
                        .resizable()
                        .frame(width: 60, height: 60)
                        .padding(.bottom)
                    Text("Down")
                        .font(.system(size: 20, weight: .bold))
                    Spacer()
                }
                .frame(minWidth: 150, maxHeight: .infinity)
                .border(Color.black)
            }
        }
    }
}

struct PageGrid: View {
    let pageLabels: [String]
    let shortPressAction: (String) -> Void
    let longPressAction: (String) -> Void
    
    var body: some View {
        GridStack(rows: 2, columns: 4, spacing: 10) { row, col in
            let index = row * 4 + col
            let label = pageLabels[index]
            
            Button(action: {
                shortPressAction(label)
            }) {
                VStack(spacing: 10) {
                    Spacer()
                    Image(systemName: "circle")
                        .resizable()
                        .frame(width: 100, height: 100)
                    Text(label.isEmpty ? "Button \(index + 1)" : label)
                        .font(.system(size: 20, weight: .bold))
                    Spacer()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .border(Color.black, width: 1)
            .simultaneousGesture(LongPressGesture().onEnded { _ in
                longPressAction(label)
            })
        }
    }
}

struct GridStack<Content: View>: View {
    let rows: Int
    let columns: Int
    let spacing: CGFloat
    let content: (Int, Int) -> Content
    
    init(rows: Int, columns: Int, spacing: CGFloat, @ViewBuilder content: @escaping (Int, Int) -> Content) {
        self.rows = rows
        self.columns = columns
        self.spacing = spacing
        self.content = content
    }
    
    var body: some View {
        VStack(spacing: spacing) {
            ForEach(0..<rows, id: \.self) { row in
                HStack(spacing: spacing) {
                    ForEach(0..<self.columns, id: \.self) { column in
                        content(row, column)
                    }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

