//
//  ResourcesView.swift
//  LessonManagmentApp
//
//  Created by Eden Fernando on 10/9/2026.
//

import SwiftUI
import SwiftData

struct ResourcesView: View {
    
    @Binding var showMenu: Bool
    @Binding var selectedSection: StudentSection
    
    @StateObject var viewModel: StudentResourcesViewModel
    let studentID: UUID
    
    @State private var searchText = ""
    @State private var sortNewestFirst = true
    @State private var selectedResource: Resource?
    
    @Binding var resourceToOpen: Resource?
    
    // filters resources by the search text and sorts them by their posted date
    private var filteredResources: [Resource] {
        
        let filtered =
        viewModel.resources.filter { resource in
            
            searchText.isEmpty
            ||
            resource.title
                .localizedCaseInsensitiveContains(
                    searchText
                )
            ||
            resource.teacherName
                .localizedCaseInsensitiveContains(
                    searchText
                )
        }
        
        return filtered.sorted {
            
            if sortNewestFirst {
                
                return $0.datePosted
                > $1.datePosted
                
            } else {
                
                return $0.datePosted
                < $1.datePosted
            }
        }
    }
    
    
    var body: some View {
        
        ZStack {
            
            ScrollView {
                
                VStack(
                    alignment: .leading,
                    spacing: 20
                ) {
                                        
                    MenuBarView(
                        showMenu: $showMenu,
                        onLogoTap: {
                            selectedSection = .home
                        }
                    )
                                        
                    Text("Resources")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                                        
                    HStack(
                        spacing: 10
                    ) {
                        
                        Image(
                            systemName:
                                "magnifyingglass"
                        )
                        .foregroundStyle(
                            .secondary
                        )
                        
                        TextField(
                            "Search resources",
                            text: $searchText
                        )
                    }
                    .padding(12)
                    .background(
                        .gray.opacity(0.12)
                    )
                    .cornerRadius(12)
                                        
                    HStack {
                        
                        Text(
                            "Resources Available"
                        )
                        .font(.headline)
                        
                        Spacer()
                        
                        Menu {
                            
                            Button(
                                "Newest First"
                            ) {
                                
                                sortNewestFirst =
                                true
                            }
                            
                            Button(
                                "Oldest First"
                            ) {
                                
                                sortNewestFirst =
                                false
                            }
                            
                        } label: {
                            
                            HStack(
                                spacing: 5
                            ) {
                                
                                Image(
                                    systemName:
                                        "arrow.up.arrow.down"
                                )
                                
                                Text(
                                    sortNewestFirst
                                    ? "Newest"
                                    : "Oldest"
                                )
                            }
                            .font(
                                .subheadline
                            )
                        }
                    }
                                        
                    if filteredResources.isEmpty {
                        
                        Text(
                            "No resources available."
                        )
                        .foregroundStyle(
                            .secondary
                        )
                        .padding(.top)
                        
                    } else {
                        
                        ForEach(
                            filteredResources,
                            id: \.id
                        ) { resource in
                            
                            Button {
                                
                                selectedResource =
                                resource
                                
                            } label: {
                                
                                resourceCard(
                                    resource
                                )
                            }
                            .buttonStyle(
                                .plain
                            )
                        }
                    }
                    
                    Spacer()
                }
                .padding()
            }
                        
            if let resource = selectedResource {
                
                Color.black
                    .opacity(0.35)
                    .ignoresSafeArea()
                    .onTapGesture {
                        selectedResource = nil
                    }
                
                ResourcePreviewView(
                    resource: resource,
                    subtitle: "From \(resource.teacherName)",
                    onClose: {
                        selectedResource = nil
                    }
                )
            }
            
        }
                
        .onAppear {

            viewModel.loadResources(
                studentID: studentID
            )

            if let resource =
                resourceToOpen {

                selectedResource =
                    resource

                resourceToOpen =
                    nil
            }
        }
    }
    
        
    // builds the reusable card layout for each resource
    private func resourceCard(
        _ resource: Resource
    ) -> some View {
        
        HStack(
            alignment: .top,
            spacing: 14
        ) {
            
            Image(
                systemName:
                    resource.fileType
                == .pdf
                ? "doc.fill"
                : "photo.fill"
            )
            .font(.title2)
            .foregroundStyle(.blue)
            .frame(
                width: 44,
                height: 44
            )
            .background(
                .blue.opacity(0.12)
            )
            .clipShape(
                RoundedRectangle(
                    cornerRadius: 10
                )
            )
            
            VStack(
                alignment: .leading,
                spacing: 6
            ) {
                
                Text(
                    resource.title
                )
                .font(.headline)
                .foregroundStyle(
                    .primary
                )
                
                Text(
                    "From \(resource.teacherName)"
                )
                .font(.subheadline)
                .foregroundStyle(
                    .secondary
                )
                
                if let lessonID = resource.lessonID,
                   let lesson = viewModel.lessons.first(
                       where: {
                           $0.id == lessonID
                       }
                   ) {

                    Text(
                        "Lesson: \(lesson.title)"
                    )
                    .font(.caption)
                    .foregroundStyle(.secondary)

                    Text(
                        "Lesson Date: \(lesson.date, style: .date)"
                    )
                    .font(.caption)
                    .foregroundStyle(.secondary)

                } else {

                    Text(
                        "General resource"
                    )
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
                
                Text(
                    "Posted \(resource.datePosted, style: .date)"
                )
                .font(.caption)
                .foregroundStyle(
                    .secondary
                )
                
                HStack {
                    
                    Text(
                        resource.fileName
                    )
                    .font(.caption)
                    .foregroundStyle(
                        .secondary
                    )
                    .lineLimit(1)
                    
                    Spacer()
                    
                    HStack(
                        spacing: 4
                    ) {
                        
                        Text("View")
                        
                        Image(
                            systemName:
                                "chevron.right"
                        )
                        .font(.caption)
                    }
                    .font(.caption)
                    .foregroundStyle(
                        .blue
                    )
                }
            }
        }
        .padding()
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .background(
            .gray.opacity(0.12)
        )
        .cornerRadius(14)
    }
}


    #Preview {

        @Previewable
        @State var showMenu = false
        
        @Previewable
        @State var resourceToOpen: Resource?
        
        @Previewable
        @State var selectedSection: StudentSection = .resources

        let studentID = UUID()

        let container =
            try! ModelContainer(
                for:
                    Resource.self,
                    Lesson.self,
                configurations:
                    ModelConfiguration(
                        isStoredInMemoryOnly: true
                    )
            )

        let resourceRepository =
            LocalResourceRepository(
                modelContext:
                    container.mainContext
            )
        
        let lessonRepository =
            LocalLessonRepository(
                modelContext: container.mainContext
            )

        ResourcesView(
            showMenu: $showMenu,
            selectedSection: $selectedSection,
            viewModel:
                StudentResourcesViewModel(
                    resourceRepository: resourceRepository,
                    lessonRepository: lessonRepository
                ),
            studentID: studentID,
            resourceToOpen: $resourceToOpen
        )
        .modelContainer(
            container
        )
    }
