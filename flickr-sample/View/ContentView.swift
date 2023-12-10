//
//  ContentView.swift
//  flickr-sample
//
//  Created by Leo Quinteros on 10/04/23.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject var viewModel: ContentViewModel
    
    var body: some View {
        ZStack {
            switch viewModel.state {
            case .loading:
                LoadingView()
            case .deniedLocation:
                AllowLocationView()
            case .error(let message):
                ErrorView(message: message)
            case .ready:
                StartButton(title: "Start") {
                    viewModel.startUpdatingLocation()
                }
            case .stopSharing:
                StartButton(title: "Resume") {
                    viewModel.startUpdatingLocation()
                }
            case .loaded(let photosURL):
                NavigationStack {
                    ScrollView {
                        ForEach(photosURL, id: \.self) { photoURL in
                            AsyncImageView(photoURL: photoURL)
                        }
                    }
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button {
                                viewModel.stopUpdatingLocation()
                            } label: {
                                Text("Stop")
                            }
                        }
                    }
                }
            }
        }
        .padding(.all, 8)
        .ignoresSafeArea()
        .animation(.default, value: viewModel.state)
        .onAppear {
            viewModel.updateLocationManager()
        }
    }
}

private struct LoadingView: View {
    var body: some View {
        ProgressView()
            .progressViewStyle(.circular)
            .tint(.primary)
    }
}

private struct ErrorView: View {
    let message: String
    
    var body: some View {
        VStack {
            Text("Error‼️")
                .font(.title)
            Text(message)
                .font(.caption2)
        }
    }
}

private struct AllowLocationView: View {
    var body: some View {
        Text("Please allow the app to track your location in Settings")
            .font(.caption2)
    }
}

private struct AsyncImageView: View {
    var photoURL: URL
    var body: some View {
        AsyncImage(url: photoURL, content: { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fit)
            },
            placeholder: {
                LoadingView()
            }
        )
    }
}

private struct StartButton: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            Text(title)
        }
        .buttonStyle(StartButtonStyle())
    }
}

private struct StartButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(width: 100)
            .padding()
            .background(.green)
            .foregroundColor(.white)
            .clipShape(Capsule())
            .scaleEffect(configuration.isPressed ? 1.2 : 1)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}
