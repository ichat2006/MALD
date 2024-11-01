//
//  ContactUsView.swift
//  MALD
//
//  Created by Ishaan
//

import SwiftUI

import SwiftUI

struct ContactUsView: View {
    @Environment(\.openURL) var openURL

    var body: some View {
            Form {
                Section(header: Text("Contact Us")) {
                    Text("If you have any questions or need assistance, feel free to reach out to us using one of the following methods.")
                }

                Section(header: Text("Contact Information")) {
                    Button(action: {
                        // Add action to initiate a call
                        openURL(URL(string: "https://forms.gle/yBgNTX9iGqyEueX69")!)

                    }) {
                        HStack {
                            Image(systemName: "phone.circle.fill")
                                .font(.title)
                            Text("Call Us")
                        }
                    }

                    Button(action: {
                        // Add action to compose an email
                        openURL(URL(string: "https://forms.gle/yBgNTX9iGqyEueX69")!)

                    }) {
                        HStack {
                            Image(systemName: "envelope.circle.fill")
                                .font(.title)
                            Text("Email Us")
                        }
                    }

                    Button(action: {
                        // Add action to open maps/navigation
                        openURL(URL(string: "https://forms.gle/yBgNTX9iGqyEueX69")!)

                    }) {
                        HStack {
                            Image(systemName: "map.fill")
                                .font(.title)
                            Text("Visit Us")
                        }
                    }
                }
            
                .navigationTitle("Contact Us")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct ContactUsView_Previews: PreviewProvider {
    static var previews: some View {
        ContactUsView()
    }
}
