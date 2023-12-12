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
                AllowLocationView {
                    viewModel.openAppSettings()
                }
            case .error(let message):
                ErrorView(message: message) {
                    viewModel.startUpdatingLocation()
                }
            case .ready:
                StartButton(title: "Start") {
                    viewModel.startUpdatingLocation()
                }
            case .stopSharing:
                VStack {
                    StartButton(title: "Restart") {
                        viewModel.startUpdatingLocation()
                    }
                    StartButton(title: "Resume") {
                        viewModel.resumeUpdatingLocation()
                    }
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
    let action: () -> Void
    var body: some View {
        ContentUnavailableView {
            Label("Unable to show photos", symbol: .photosUnavailable)
        } description: {
            Text("Description: \(message)")
        } actions: {
            Button("Try again") {
                action()
            }
        }
    }
}

private struct AllowLocationView: View {
    let action: () -> Void
    
    var body: some View {
        ContentUnavailableView {
            Label("Unable to show photos", symbol: .locationUnavailable)
        } description: {
            Text("Please allow the app to track your location on Settings")
        } actions: {
            Button("Open") {
                action()
            }
        }
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
