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
    
    // State variables for todo editor sheet
    @State private var showingTodoEditor = false
    @State private var selectedTodoIndex = 0
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(todos.indices, id: \.self) { index in
                        VStack(alignment: .leading) {
                            Text(todos[index].title)
                                .font(.headline)
                            Text(todos[index].description)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text(formatDate(todos[index].dueDate))
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        //select and hold on a todo item to reveal contextMenu
                        .contextMenu {
                            Button(action: {
                                removeTodo(at: index)
                            }) {
                                Text("Remove")
                                Image(systemName: "trash")
                            }
                            Button(action: {
                                // Set selected todo index for editing
                                selectedTodoIndex = index
                                showingTodoEditor = true
                            }) {
                                Text("Edit")
                                Image(systemName: "square.and.pencil")
                            }
                        }
                    }
                }
                // Sheet to edit a selected todo item
                .sheet(isPresented: $showingTodoEditor) {
                    TodoEditor(todo: $todos[selectedTodoIndex], onSave: saveTodos)
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

    //function to remove the todo in the storage
    private func removeTodo(at index: Int) {
        todos.remove(at: index)
        // Update storage after removal
        saveTodos()
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

//TodoEditor View to display the details of a selected todo item for editing
struct TodoEditor: View {
    @Binding var todo: TodoItem
    let onSave: () -> Void

    var body: some View {
        VStack {
            Text("Update Todo")
                .fontWeight(.bold) // Make title bold
                .padding(.top, 20) // Add top padding
            
            TextField("Title", text: $todo.title)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
            TextField("Description", text: $todo.description)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
            DatePicker("Due Date", selection: $todo.dueDate, displayedComponents: .date)
                .datePickerStyle(DefaultDatePickerStyle())
                .labelsHidden()
                .padding()
            
            //saves the updated todo to the userdefault storage
            Button(action: onSave) {
                Text("Save")
            }
            .padding()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}



