//
//  ContentView.swift
//  komoot-test
//
//  Created by Leo Quinteros on 10/04/23.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject var viewModel: ContentViewModel
    
    var body: some View {
        ZStack {
            if viewModel.shouldShowStartButton {
                VStack {
                    Button {
                        viewModel.startUpdatingLocation()
                    } label: {
                        if viewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(.circular)
                                .tint(.white)
                        } else {
                            Text("Start")
                        }
                    }
                    .buttonStyle(StartButton())
                    .disabled(viewModel.hasDeniedLocation || viewModel.isLoading)
                    if viewModel.hasDeniedLocation {
                        AllowLocationView()
                    }
                }
            } else {
                NavigationStack {
                    ScrollView {
                        if viewModel.hasDeniedLocation {
                            AllowLocationView()
                        } else {
                            ForEach(viewModel.photosURL, id: \.self) { photoURL in
                                AsyncImageView(photoURL: photoURL)
                            }
                        }
                    }
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button {
                                viewModel.startUpdatingLocation()
                            } label: {
                                Text("Restart")
                            }
                            .disabled(viewModel.restartButtonDisabled)
                        }
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button {
                                viewModel.stopUpdatingLocation()
                            } label: {
                                Text("Stop")
                            }
                            .disabled(viewModel.stopButtonDisabled)
                        }
                    }
                }
            }
        }
        .padding(.all, 8)
        .ignoresSafeArea()
        .onAppear {
            viewModel.setupLocationManager()
        }
    }
}

private struct StartButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(width: 50)
            .padding()
            .background(.blue)
            .foregroundColor(.white)
            .clipShape(Capsule())
            .scaleEffect(configuration.isPressed ? 1.2 : 1)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
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
                ProgressView()
            }
        )
    }
}

