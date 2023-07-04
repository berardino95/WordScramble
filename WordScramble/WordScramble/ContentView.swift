//
//  ContentView.swift
//  WordScramble
//
//  Created by CHIARELLO Berardino - ADECCO on 03/05/23.
//

import SwiftUI

struct ContentView: View {
    
    @State private var userWord = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    
    @State private var score = 0
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    TextField("Enter your word", text: $newWord)
                        .textInputAutocapitalization(.never) //turn off capitalization
                        .autocorrectionDisabled(true)
                }
                
                Section {
                    ForEach(userWord, id: \.self) { word in
                        HStack{
                            //add a circle with a number that display the number of character in the word
                            Image(systemName: "\(word.count).circle.fill")
                                .foregroundColor(.blue)
                            Text(word)
                        }
                        .accessibilityElement()
                        .accessibilityLabel("world \(word ) worth \(word.count) points")
                    }
                }
            }
            .navigationTitle(rootWord)
            .onSubmit(addNewWord)
            .onAppear(perform: startGame)
            .alert(errorTitle, isPresented: $showingError) {
                Button("Ok", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
            .toolbar {
                Button("Restart", action: startGame)
            }
            //Add an item that work as a safe area, alle the element can be covered from this text belove
            .safeAreaInset(edge: .bottom) {
                Text("Score: \(score)")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.mint)
                    .font(.title3.bold())
                    .foregroundColor(.white)
                    .accessibilityLabel("Your score is \(score) \(score == 1 ? "point" : "points")")
            }
        }
    }
    
    //the function used onSubmit to check the next and reset the text field
    func addNewWord(){
        //lowercase the word and remove white spaces
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        //check if the answer isn't empty
        guard answer.count > 3 else {
            wordError(title: "Word shorter", message: "The word must be 3+ letter")
            return }
        
        //Checking if the word entered is equal to the rootWord
        guard isNotEqual(word: answer) else {
            wordError(title: "Word invalid", message: "You word is the same as given word")
            return
        }
        
        //checking if te word was already entered
        guard isOriginal(word: answer) else {
            wordError(title: "World used already", message: "Be more original")
            return
        }
        
        //Check if the word can create from the given word
        guard isPossible(word: answer) else {
            wordError(title: "Word not possible", message: "You can't spell that word from '\(rootWord)'")
            return
        }
        
        //Checking for misspelling error
        guard isReal(word: answer) else {
            wordError(title: "Word not recognized", message: "You can't just make them up, you know!")
            return
        }
        
        score += newWord.count
        
        //adding animation when appending item in the array, the result is much smother
        withAnimation{
            //adding the word at the start of the array
            userWord.insert(answer, at: 0)
        }
        //resetting the textfield
        newWord = ""
    }
    
    
    //The function calle onAppear that load the word from the file and convert it into an array of string passing only 1 random word to the @State var rootWord
    func startGame(){
        
        newWord = ""
        userWord .removeAll()
        score = 0
        
        //asking Xcode to retrive the url of start.txt file
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt"){
            //load the file into a string
            if let startWords = try? String(contentsOf: startWordsURL) {
                //split in an array of string
                let allWords = startWords.components(separatedBy: "\n")
                
                //retrive a random word and assign it to rootWord
                rootWord = allWords.randomElement() ?? "silkworm"
                return
            }
        }
        //If the app can't load the file, with fatal error the app will crash and will show the message in the console
        fatalError("Could not load start.txt")
    }
    
    //check if the word was already entered by the user
    func isOriginal(word: String) -> Bool {
        return !userWord.contains(word)
    }
    
    //This func check the user input and the given word, they must have the same letter, if only one letter is different return false
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord
        
        for letter in word {
            //check where the letter is in the user word and return a position index
            if let position = tempWord.firstIndex(of: letter){
                //remove the letter passing the position
                tempWord.remove(at: position)
            } else {
                return false
            }
        }
        
        return true
    }
    
    //Checking our string for misspell word
    func isReal(word: String) -> Bool{
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspellRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return misspellRange.location == NSNotFound
    }
    
    func isNotEqual(word: String) -> Bool {
        return !(word == rootWord)
    }
    
    //func to set the alert title and message
    func wordError (title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
