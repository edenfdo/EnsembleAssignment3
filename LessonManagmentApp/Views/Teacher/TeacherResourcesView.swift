//
//  TeacherResourcesView.swift
//  LessonManagmentApp
//
//  Created by Eden Fernando on 12/9/2026.
//


import SwiftUI

struct TeacherResourcesView: View {

    @Binding var showMenu: Bool
    @Binding var selectedSection: TeacherSection

    let teacher: User

    @StateObject var viewModel: TeacherResourcesViewModel

    @State private var showAddResourceSheet = false
    @State private var selectedResource: Resource?

    
    @State private var resourceToEdit: Resource?
    @State private var resourceToDelete: Resource?
    @State private var showDeleteAlert = false
    
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

                    Text(
                        "Share learning resources with your students."
                    )
                    .foregroundStyle(.secondary)


                    Button {

                        showAddResourceSheet = true

                    } label: {

                        HStack {

                            Image(
                                systemName: "plus"
                            )

                            Text("Add Resource")
                                .fontWeight(.semibold)

                            Spacer()
                        }
                        .padding()
                        .foregroundStyle(.white)
                        .background(.blue)
                        .cornerRadius(12)
                    }
                    .buttonStyle(.plain)

                    Text("Shared Resources")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.top, 4)

                    if viewModel.resources.isEmpty {

                        Text(
                            "No resources shared yet."
                        )
                        .foregroundStyle(.secondary)

                    } else {

                        ForEach(
                            viewModel.resources,
                            id: \.id
                        ) { resource in

                            resourceCard(
                                resource
                            )
                            .buttonStyle(.plain)
                        }
                    }

                    Spacer()
                }
                .padding()
            }

            if let resource =
                selectedResource {

                Color.black
                    .opacity(0.35)
                    .ignoresSafeArea()
                    .onTapGesture {

                        selectedResource =
                            nil
                    }

                VStack(
                    spacing: 12
                ) {

                    ResourcePreviewView(
                        resource: resource,
                        subtitle:
                            popupSubtitle(
                                for: resource
                            ),
                        onClose: {
                            selectedResource = nil
                        }
                    )

                    
                }
            }
        }

        .onAppear {

            viewModel.loadData(
                teacherID: teacher.id
            )
        }

        .sheet(
            isPresented:
                $showAddResourceSheet
        ) {

            AddResourceView(
                teacher: teacher,
                viewModel: viewModel
            )
        }
        .sheet(
            item: $resourceToEdit
        ) { resource in

            EditResourceView(
                resource: resource,
                teacher: teacher,
                viewModel: viewModel
            )
        }
        .alert(
            "Delete Resource?",
            isPresented: $showDeleteAlert
        ) {

            Button(
                "Cancel",
                role: .cancel
            ) {
                resourceToDelete = nil
            }

            Button(
                "Delete",
                role: .destructive
            ) {

                if let resource = resourceToDelete {

                    viewModel.deleteResource(
                        resource,
                        teacherID: teacher.id
                    )
                }

                resourceToDelete = nil
            }

        } message: {

            Text(
                "Are you sure you want to delete this resource? This action cannot be undone."
            )
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
                    resource.fileType == .pdf
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

                HStack {

                    Text(
                        resource.title
                    )
                    .font(.headline)
                    .foregroundStyle(.primary)

                    Spacer()

                    Menu {

                        Button {

                            resourceToEdit = resource

                        } label: {

                            Label(
                                "Edit Resource",
                                systemImage: "pencil"
                            )
                        }

                        Button(
                            role: .destructive
                        ) {

                            resourceToDelete = resource
                            showDeleteAlert = true

                        } label: {

                            Label(
                                "Delete Resource",
                                systemImage: "trash"
                            )
                        }

                    } label: {

                        Image(
                            systemName: "ellipsis"
                        )
                        .font(.headline)
                        .frame(
                            width: 30,
                            height: 30
                        )
                        .background(
                            Color.gray.opacity(0.12)
                        )
                        .clipShape(
                            RoundedRectangle(
                                cornerRadius: 8
                            )
                        )
                        .foregroundStyle(.primary)
                    }
                }

                if let student =
                    viewModel.studentForResource(
                        resource
                    ) {

                    Text(
                        "Student: \(student.name)"
                    )
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                }

                if let lessonID =
                    resource.lessonID,
                   let lesson =
                    viewModel.lessons.first(
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
                    "Shared \(resource.datePosted, style: .date)"
                )
                .font(.caption)
                .foregroundStyle(.secondary)


                HStack {

                    Text(
                        resource.fileName
                    )
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)

                    Spacer()

                    Button {

                        selectedResource = resource

                    } label: {

                        HStack(
                            spacing: 4
                        ) {

                            Text("View")

                            Image(
                                systemName: "chevron.right"
                            )
                            .font(.caption)
                        }
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.blue)
                    }
                    .buttonStyle(.plain)
                }
            }

            Spacer()
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
    
    // creates the preview subtitle based on the student the resource was shared with
    private func popupSubtitle(
        for resource: Resource
    ) -> String {

        if let student =
            viewModel.studentForResource(
                resource
            ) {

            return "Shared with \(student.name)"
        }

        return "Shared resource"
    }
}
