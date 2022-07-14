//
//  AppDelegate.swift
//  SalesmanLearner
//
//  Created by Егор Шереметов on 04.06.2022.
//

import UIKit
import CoreData

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        let values: [[Double]] = [
            [-1, 6, 3, 5, 4, 2],
            [4, -1, 3, 4, 2, 3],
            [5, 4, -1, 4, 3, 2],
            [2, 3, 4, -1, 5, 6],
            [4, 6, 6, 7, -1, 5],
            [3, 2, 4, 3, 5, -1]
        ]
        
        let matrix = Matrix<Double, Int>(values: values)
        for i in matrix.rowIndexes {
            matrix[i][i] = Double.infinity
        }

        let solver = SolverTree()

        // INITIAL
        let initialPrepare = solver.prepare(matrix: matrix)
        let initialNode = SolverTreeNode(point: (0, 0), value: initialPrepare.1, type: .initial, matrix: initialPrepare.matrix)
        print("PREPARED MATRIX:\n\(initialPrepare.matrix)\n")
        print("VALUE: \(initialPrepare.value)\n")

        // CALC NEXT POINT
        print("\nCALC FIRST")
        let zeroFirst = solver.getMaxZero(from: initialPrepare.matrix)
        print("CHOSEN POINT: \(zeroFirst.0) with value: \(zeroFirst.1)\n")

        let includeNodeFirst = solver.getIncludePoint(point: zeroFirst.0, initialNode)
        let excludeNodeFirst = solver.getExcludePoint(point: zeroFirst.0, value: zeroFirst.1, initialNode)

        print("INCLUDE: ")
        print(includeNodeFirst.matrix.info())
        print("\n")

        // CALC NEXT POINT (INCLUDE CHOSEN)
        print("\nCALC SECOND")
        let zeroSecond = solver.getMaxZero(from: includeNodeFirst.matrix)
        print("\nCHOSEN POINT: \(zeroSecond.0) with value: \(zeroSecond.1)\n")

        let includeNodeSecond = solver.getIncludePoint(point: zeroSecond.0, includeNodeFirst)
        let excludeNodeSecond = solver.getExcludePoint(point: zeroSecond.0, value: zeroSecond.1, includeNodeFirst)

        print("INCLUDE: ")
        print(includeNodeSecond.matrix.info())
        print("\n")

        // CALC NEXT POINT (INCLUDE CHOSEN)
        print("\nCALC THIRD")
        let zeroThird = solver.getMaxZero(from: includeNodeSecond.matrix)
        print("\nCHOSEN POINT: \(zeroThird.0) with value: \(zeroThird.1)\n")

        let includeNodeThird = solver.getIncludePoint(point: zeroThird.0, includeNodeSecond)
        let excludeNodeThird = solver.getExcludePoint(point: zeroThird.0, value: zeroThird.1, includeNodeSecond)

        print("INCLUDE: ")
        print(includeNodeThird.matrix.info())
        print("\n")

        // CALC NEXT POINT (INCLUDE CHOSEN)
        print("\nCALC FOURTH")
        let zeroFourth = solver.getMaxZero(from: includeNodeThird.matrix)
        print("\nCHOSEN POINT: \(zeroFourth.0) with value: \(zeroFourth.1)\n")

        let includeNodeFourth = solver.getIncludePoint(point: zeroFourth.0, includeNodeThird)
        let excludeNodeFourth = solver.getExcludePoint(point: zeroFourth.0, value: zeroFourth.1, includeNodeThird)

        print("INCLUDE: ")
        print(includeNodeFourth.matrix.info())
        print("\n")

        print(solver.points)

        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "SalesmanLearner")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

