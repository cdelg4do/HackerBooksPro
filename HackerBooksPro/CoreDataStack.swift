//
//  CoreDataStack.swift
//
//
//  Created by Carlos Delgado on 19/09/16.
//  (based on previous work from Fernando Rodríguez Romero)
//

import CoreData


struct CoreDataStack {
    
    // Propiedades (con fileprivate en vez de private, son accesibles fuera e este bloque, p.ej en una extensión)
    
    fileprivate let modelURL : URL                  // url del esquema xcdatamodel del modelo en el filesystem
    fileprivate let model : NSManagedObjectModel    // el modelo descrito en el xcdatamodel
    
    fileprivate let dbURL : URL                     // Url de la BBDD en el filesystem
    
    // Contextos (contenedores de los objetos, cada uno tiene asociada una cola propia para ejecutar las operaciones de Core Data)
    fileprivate let persistingContext : NSManagedObjectContext  // contexto de persistencia, solo para guardar a disco (en segundo plano)
    fileprivate let backgroundContext : NSManagedObjectContext  // contexto operaciones en 2o plano
    let context : NSManagedObjectContext                        // contexto operaciones en cola principal (actualizar vistas, etc)
    
    fileprivate let coordinator : NSPersistentStoreCoordinator  // intermediario entre los contextos y los stores físicos
    
    
    
    // Inicializador: carga el modelo de nombre indicado e inicializa todas las estructuras necesarias para trabajar con él
    // (si alguna operación falla, devolverá nil)
    
    init?(modelName: String) {
        
        // Obtener la url del esquema (se asume que está en el main bundle de la app)
        // e incicializar el modelo con los contenidos de dicho fichero
        guard let modelURL = Bundle.main.url(forResource: modelName, withExtension: "momd") else {
            print("\nERROR: Unable to find \(modelName) in the main bundle\n")
            return nil
        }
        
        self.modelURL = modelURL
        
        guard let model = NSManagedObjectModel(contentsOf: modelURL) else {
            print("\nERROR: Unable to create a model from \(modelURL)\n")
            return nil
        }
        
        self.model = model
        
        
        // Creamos un Store Coordinator, asociado a nuestro modelo
        coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        
        // Crear los 3 contextos que usaremos (uno en la cola principal y los otros dos en colas propias en 2o plano)
        context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        backgroundContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        persistingContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        
        // Jerarquía (de padres a hijos): StoreCoordinator > persistingContext > context > backgroundContext
        backgroundContext.parent = context
        context.parent = persistingContext
        persistingContext.persistentStoreCoordinator = coordinator
        
        
        // Por último, asociar el Store Coordinator con un store de tipo SQLite almacenado en la carpera Documents
        guard let docUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("\nERROR: Unable to reach the Documents folder\n")
            return nil
        }
        
        self.dbURL = docUrl.appendingPathComponent("model.sqlite")
        
        do {
            try addStoreToCoordinator(NSSQLiteStoreType, storeURL: dbURL)
        }
        catch {
            print("\nERROR: Unable to add store at \(dbURL)\n")
        }
        
    }
    
    
    // Función auxiliar que asocia a nuestro StoreCoordinator con un store del tipo y la ubicación indicados
    // (si no existía ya, se crea físicamente el store)
    func addStoreToCoordinator(_ storeType: String, storeURL: URL) throws {
        
        // Opciones para migración de versiones (por si ya existe en el dispositivo un store de otra versión anterior del modelo):
        // Migración de manera automática, haciendo que sea Core Data infiera él solo cómo hacerlo.
        let migrationOptions = [NSMigratePersistentStoresAutomaticallyOption: true,
                                NSInferMappingModelAutomaticallyOption: true ]
        
        try coordinator.addPersistentStore(ofType: storeType, configurationName: nil, at: storeURL, options: migrationOptions)
    }
    
}


// Vaciado del store
extension CoreDataStack  {
    
    // Función auxiliar para eliminar todos los objetos almacenados, para tests, etc.
    // (deja un store con todas las tablas vacías)
    func dropAllData() throws{
        
        try coordinator.destroyPersistentStore(at: dbURL, ofType:NSSQLiteStoreType , options: nil)
        try addStoreToCoordinator(NSSQLiteStoreType, storeURL: dbURL)
    }
    
}


// MARK:  - Batch processing in the background
extension CoreDataStack {
    
    // Tipo de función "Batch" que realiza operaciones de Core Data en un contexto determinado
    typealias Batch = (_ workerContext: NSManagedObjectContext) -> ()
    
    
    // Función para realizar operaciones en segundo plano (utilizando la función de tipo Bath indicada)
    // (@escaping indica al compilador que la función Batch puede que se ejecute después de que haya finalizado performBackgroundBatchOperation() )
    func performBackgroundBatchOperation(_ batch: @escaping Batch){
        
        // Perform() ejecuta un bloque en la cola asociada al contexto (este caso, en segundo plano)
        backgroundContext.perform() {
            
            // Ejecutamos la operación indicada, usando el contexto de segundo plano
            batch(self.backgroundContext)
            
            // Tras ejecutar la operación, se guardan los cambios para que sean visibles en el contexto padre
            do {
                try self.backgroundContext.save()
            }
            catch {
                fatalError("\nERROR: Unable to save backgroundContext: \(error)")
            }
        }
    }
    
}


// MARK:  - Save
extension CoreDataStack {
    
    // Función para guardar los cambios en disco
    // (primero consolida los cambios del contexto principal, y después los guarda en disco en segundo plano)
    func save() {
        
        // NOTA:
        //
        // El método save() de NSManagedObjectContext intenta plasmar los cambios no guardados de un contexto
        // en el store padre (que puede ser otro contexto o un store coordinator):
        //
        // - Si el padre es otro contexto, símplemente los cambios se hacen visibles en el contexto padre (en memoria)
        // - Si es un Store Coordinator, se consolidan los cambios en disco (SQLite, etc).
        
        
        // PerformAndWait() ejecuta un bloque de manera secuencial en la cola asociada al contexto
        // (se queda bloqueado hasta que termine cada paso)
        context.performAndWait() {
            
            // Solo se efectúa el guardado si hay cambios que guardar en el contexto principal
            if self.context.hasChanges {
                
                // Guarda los cambios del contexto principal, haciéndolos visibles en el contexto de persistencia
                // (aunque se hace en la cola principal esto no tiene mucho impacto, ya que no se accede al disco)
                do {
                    try self.context.save()
                }
                catch {
                    fatalError("\nERROR: Unable to save main context: \(error)")
                }
                
                // Una vez actualizado el contexto principal indicamos al contexto de persistencia que,
                // en su cola particular (2o plano), guarde los cambios en disco
                self.persistingContext.perform() {
                    
                    do {
                        try self.persistingContext.save()
                    }
                    catch {
                        fatalError("\nERROR: Unable to save persisting context: \(error)")
                    }
                }
            }
        }
        
    }
    
    
    // Función que realiza el salvado de objetos cada cierto tiempo
    func autoSave(_ delayInSeconds : Int) {
        
        if delayInSeconds > 0 {
            
            // Salvar
            print("Autosaving...")
            save()
            
            // Calcular la hora del siguiente autosalvado
            let delayInNanoSeconds = UInt64(delayInSeconds) * NSEC_PER_SEC
            let time = DispatchTime.now() + Double(Int64(delayInNanoSeconds)) / Double(NSEC_PER_SEC)
            
            // Encolar una nueva llamada a autoSave() en la cola principal, para que se ejecute en la hora calculada
            DispatchQueue.main.asyncAfter(deadline: time, execute: { self.autoSave(delayInSeconds) } )
        }
        
    }
    
}

