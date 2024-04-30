// ContentView.swift
import SwiftUI
import Foundation

struct ContentView: View {
    //key for storing todo items in userdefault
    let todosKey = "todos"
    
    //user inputs
    @State private var newTodoTitle = ""
    @State private var newTodoDescription = ""
    @State private var newTodoDueDate = Date()
    
    // For date choosing
    @State private var showingDatePicker = false
    
    //array to hold the todo items
    @State private var todos: [TodoItem] = []
    
    var body: some View {
        NavigationView {
            VStack {
                List(todos) { todo in
                    VStack(alignment: .leading) {
                        Text(todo.title)
                            .font(.headline)
                        Text(todo.description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text(formatDate(todo.dueDate))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .navigationBarTitle("Todo List", displayMode: .inline)
                
                Button(action: addTodo) {
                    Text("Add Todo")
                        .foregroundColor(.black)
                }
                .buttonStyle(BorderlessButtonStyle())
                .padding(.horizontal)
                .padding(.vertical, 8)
 
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.black, lineWidth: 1)
                )
                .hoverEffect(.highlight) // Apply hover effect

                
                //field for user inputs
                TextField("Title", text: $newTodoTitle)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                TextField("Description", text: $newTodoDescription)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                TextField("DueDate", text: Binding<String>(
                    get: {
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "MM-dd-yyyy"
                        return dateFormatter.string(from: self.newTodoDueDate)
                    },
                    set: { newValue in
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "MM-dd-yyyy"
                        if let newDate = dateFormatter.date(from: newValue) {
                            self.newTodoDueDate = newDate
                        }
                    }))
                    .onTapGesture {
                        self.showingDatePicker = true
                    }
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    if showingDatePicker {
                        DatePicker("Select a due date: ", selection: $newTodoDueDate, displayedComponents: .date)
                            .datePickerStyle(DefaultDatePickerStyle())
                            .labelsHidden()
                    }
            }
        }

        .onAppear {
            //gets the todos from userdefault when the view pops up
            fetchTodos()
        }
        
    }
    
    //adds the todo item to userdefault storage
    private func addTodo() {
        guard !newTodoTitle.isEmpty && !newTodoDescription.isEmpty && newTodoDueDate != Date() else {
            return
        }
        
        let todo = TodoItem(title: newTodoTitle, description: newTodoDescription, dueDate: newTodoDueDate)
        
        //adds todo to the array
        todos.append(todo)
        
        //adds todo to the userdefault storage
        saveTodos()
        
        //removes the user input in the view
        newTodoTitle = ""
        newTodoDescription = ""
        newTodoDueDate = Date()
    }
    
    //function to save the todos to the storage
    private func saveTodos() {
        do {
            let data = try JSONEncoder().encode(todos)
            UserDefaults.standard.set(data, forKey: todosKey)
        } catch {
            print("Error encoding todos: \(error.localizedDescription)")
        }
    }
    
    //gets todos from the storage
    private func fetchTodos() {
        if let data = UserDefaults.standard.data(forKey: todosKey) {
            do {
                todos = try JSONDecoder().decode([TodoItem].self, from: data)
            } catch {
                print("Error decoding todos: \(error.localizedDescription)")
            }
        }
    }
}

func formatDate(_ date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MM-dd-yyyy"
    return dateFormatter.string(from: date)
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}



