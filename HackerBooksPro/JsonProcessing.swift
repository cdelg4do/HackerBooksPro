//
//  JsonProcessing.swift
//  HackerBooks
//
//  Created by Carlos Delgado on 10/07/16.
//  Copyright © 2016 CDA. All rights reserved.
//

import Foundation
import UIKit

import CoreData     // para usar NSManagedObjectContext


// Tipos auxiliares para el tratamiento de JSON

typealias JsonObject        = AnyObject
typealias JsonDictionary    = [String : JsonObject]
typealias JsonList          = [JsonDictionary]


// Clausura de finalización, función que recibe un Bool
// y que se ejecutará siempre en la cola principal

typealias boolClosure = (Bool) -> ()



// Función que realiza la descarga del JSON remoto y la posterior carga de datos en el modelo
// (todo ello en segundo plano)

func generateData(fromRemoteUrl url: String, inContext context: NSManagedObjectContext, activityIndicator: UIActivityIndicatorView?, completion: @escaping boolClosure) -> () {
    
    print("\nGenerando datos iniciales desde JSON remoto...\n")
    activityIndicator?.isHidden = false
    activityIndicator?.startAnimating()
    
    DispatchQueue.global(qos: .userInitiated).async {
        
        let jsonData: JsonList?
        
        // Descarga de datos remotos (en segundo plano)
        do {
            
            jsonData = downloadJson(fromUrl: url)
            if jsonData == nil {  throw JsonError.unableToGetDataFromRemoteJson   }
        }
        
        // Si hubo fallos ejecutamos la clausura de finalización en la cola principal
        // pasando false como resultado de la operación
        catch {
            
            DispatchQueue.main.async {
                
                activityIndicator?.stopAnimating()
                activityIndicator?.isHidden = true
            
                completion(false)
                return
            }
        }
        
        // Procesamiento de los datos descargados (en segundo plano)
        decodeBookList(fromList: jsonData!, inContext: context)
        
        // Una vez procesados y cargados los datos en el modelo ejecutamos la clausura de finalización
        // en la cola principal, pasando true como resultado de la operación
        DispatchQueue.main.async {
            
            activityIndicator?.stopAnimating()
            activityIndicator?.isHidden = true
            
            completion(true)
            return
        }
    }
    
}



// Función que trata de descargar un fichero remoto y parsear su contenido,
// devolviendo el objeto JsonList correspondiente (si no lo consigue, devuelve nil)

func downloadJson(fromUrl urlString: String) -> JsonList? {
    
    // Intentar descargar el contenido del fichero remoto en un objeto Data
    print("\nDescargando JSON remoto desde \(urlString)...")
    
    let fileData: Data?
    
    guard let url = URL(string: urlString) else { return nil }
    
    do {
        fileData = try Data(contentsOf: url)
    }
    catch { return nil }
    
    if fileData == nil { return nil }
    
    
    // Intentar parsear los datos recibidos como JsonList
    print("\nParseando datos descargados...")
    
    guard let maybeList = try? JSONSerialization.jsonObject(with: fileData!, options: JSONSerialization.ReadingOptions.mutableContainers) as? JsonList, let jsonList = maybeList else {
        
        return nil
    }
    
    return jsonList
}



// Función que trata de decodificar los datos de los libros a partir de una lista de objetos JsonDictionary
// (si se produce algún error al procesar alguno de los JsonDictionary, se muestra el error en el log y se pasa al siguiente elemento)

func decodeBookList(fromList jsonList: JsonList, inContext context: NSManagedObjectContext) -> () {
    
    print("\nConstruyendo objetos del modelo a partir de los datos descargados...\n")
    
    for jsonElement in jsonList {
        
        do {
            try decodeBook(fromElement: jsonElement, inContext: context)
        }
        catch {
            print("\n** Error al procesar elemento JSON: \(jsonElement) **\n")
        }
    }
    
    // Por último creamos el tag de favoritos, que inicialmente no estará asociado a ningún libro
    // (la propiedad proxyForSorting del tag comienza por un _ para que aparezca primero en la lista)
    let _ = Tag(name: "My Favorites", proxyForSorting: "_favorites", inContext: context)
}



// Función que trata de decodificar los datos de un libro a partir de un objeto JsonDictionary

func decodeBook(fromElement json: JsonDictionary, inContext context: NSManagedObjectContext) throws -> () {
    
    // Primero, se intenta obtener del JsonDictionary todos los datos relevantes
    //print("\nDecodificando elemento: \(json)...\n")
    
    // Título del libro
    guard let bookTitle = json["title"] as? String else { throw JsonError.wrongJSONFormat }
    
    // URL de la portada (comprobando que la cadena represente a una URL)
    guard let imageUrlString = json["image_url"] as? String else {  throw JsonError.wrongJSONFormat }
    guard NSURL(string: imageUrlString) != nil else { throw JsonError.wrongURLFormatForJSONResource }
    
    // URL del PDF (comprobando que la cadena represente a una URL)
    guard let pdfUrlString = json["pdf_url"] as? String else {  throw JsonError.wrongJSONFormat }
    guard NSURL(string: pdfUrlString) != nil else { throw JsonError.wrongURLFormatForJSONResource }
    
    // Autores del libro
    guard let authorsString = json["authors"] as? String else { throw JsonError.wrongJSONFormat }
    let bookAuthors = authorsString.components(separatedBy: ", ")
    
    // Tags del libro
    guard let tagsString = json["tags"] as? String else { throw JsonError.wrongJSONFormat }
    let bookTags = tagsString.components(separatedBy: ", ")
    
    
    // Si hemos podido extraer todos los elementos del JsonDictionary sin fallo,
    // ya podemos crear y/o relacionar los managed objects
    
    // Portada y Pdf del libro (inicialmente, solo contendrán las URLs)
    let bookCover = Cover(url: imageUrlString, inContext: context)
    let bookPdf = Pdf(url: imageUrlString, inContext: context)
    
    // Creación del libro, asociando al mismo la portada y el pdf anteriores
    let newBook = Book(title: bookTitle, cover: bookCover, pdf: bookPdf, inContext: context)
    
    
    
    // Para cada autor de la lista de autores, comprobar si ya existe dicho autor
    // Si existe obtenemos una referencia al mismo, y si no lo creamos
    // Por último, asociamos el autor con el libro
    
    let authorsReq = NSFetchRequest<Author>(entityName: Author.entityName)
    
    for authorName in bookAuthors {
        
        let thisAuthor: Author
        let result: [Author]
        
        authorsReq.predicate = NSPredicate(format: "name == %@", authorName)
        
        do {    result = try context.fetch(authorsReq)  }
        catch { throw CoreDataError.fetchRequestFailure }
        
        if result.count == 0 {  thisAuthor = Author(name: authorName, inContext: context)   }
        else                 {  thisAuthor = result.first!                                  }
        
        newBook.addToAuthors(thisAuthor)
    }
    
    
    // Para cada tag de la lista de tags, comprobar si ya existe dicho tag
    // Si existe obtenemos una referencia al mismo, y si no lo creamos
    // Por último, creamos una nueva entidad bookTag que asocie al tag con el libro
    
    let tagsReq = NSFetchRequest<Tag>(entityName: Tag.entityName)
    tagsReq.fetchBatchSize = 50
    tagsReq.sortDescriptors = [ NSSortDescriptor(key: "name", ascending: false) ]
    
    for tagName in bookTags {
        
        let thisTag: Tag
        let result: [Tag]
        
        tagsReq.predicate = NSPredicate(format: "name == %@", tagName)
        
        do {    result = try context.fetch(tagsReq)     }
        catch { throw CoreDataError.fetchRequestFailure }
        
        if result.count == 0 {  thisTag = Tag(name: tagName, proxyForSorting: tagName, inContext: context)  }
        else                 {  thisTag = result.first!                                                     }
        
        let _ = BookTag(book: newBook, tag: thisTag, inContext: context)
    }
    
}


