//
//  OnboardingView.swift
//  AC Widget
//
//  Created by Cameron Shemilt on 03.04.21.
//

import SwiftUI

struct OnboardingView: View {
    @State private var selection = 0
    
    @State private var issuerID = ""
    @State private var keyID = ""
    @State private var key = ""
    @State private var vendor = ""
    
    var body: some View {
        TabView(selection: $selection) {
            welcomeSection
                .padding()
                .tag(0)
            
            issuerIDSection
                .padding()
                .tag(1)
            
            privateKeyIDSection
                .padding()
                .tag(2)
            
            privateKeySection
                .padding()
                .tag(3)
            
            VendorNrSection
                .padding()
                .tag(4)
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
    }
    
    
    // MARK: Pages
    var welcomeSection: some View {
        VStack {
            Text("Welcome")
            
            nextButton
        }
    }
    
    var issuerIDSection: some View {
        VStack {
            Text("issuerID")
            
            TextField("Issuer ID", text: $issuerID)
            
            nextButton
                .disabled(issuerID.isEmpty)
        }
    }
    
    var privateKeyIDSection: some View {
        VStack {
            Text("Private Key ID")
            
            TextField("Private Key ID", text: $keyID)
            
            nextButton
                .disabled(keyID.isEmpty)
        }
    }
    
    var privateKeySection: some View {
        VStack {
            Text("Private Key")
            
            TextEditor(text: $key)
            
            nextButton
                .disabled(key.isEmpty)
        }
    }
    
    var VendorNrSection: some View {
        VStack {
            Text("Vendor Nr.")
            
            TextField("Vendor Nr.", text: $vendor)
            
            nextButton
                .disabled(vendor.isEmpty)
        }
    }
    
    
    // MARK: Next Button
    var nextButton: some View {
        Button(action: onNextPress, label: {
            Text(selection < 4 ? "Next" : "Finish")
                .font(.system(size: 18, weight: .bold))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .foregroundColor(.white)
                .background(Color.accentColor)
                .clipShape(Capsule())
                .contentShape(Rectangle())
        })
    }
    
    private func onNextPress() {
        if selection < 4 {
            selection += 1
        } else {
            defer { UserDefaults.standard.set(true, forKey: "completedOnboarding") }
            UserDefaults.shared?.setValue(issuerID, forKey: UserDefaultsKey.issuerID)
            UserDefaults.shared?.setValue(keyID, forKey: UserDefaultsKey.privateKeyID)
            UserDefaults.shared?.setValue(key, forKey: UserDefaultsKey.privateKey)
            UserDefaults.shared?.setValue(vendor, forKey: UserDefaultsKey.vendorNumber)
        }
    }
    
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
    }
}
