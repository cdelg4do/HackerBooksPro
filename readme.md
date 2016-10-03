# Práctica iOS Avanzado de Carlos Delgado Andrés

**HackerBooksPro** es un prototipo de aplicación para iOS realizada en Swift 3.0 y Xcode 8.

Se trata de un lector de libros en PDF para iPhone, evolución del anterior *HackerBooks* realizado en Swift 2.2, que incorpora la búsqueda de libros por título, autor o tag, y la creación de notas con foto por parte del usuario.

Se hace uso de *GCD* (Grand Central Dispatch) para la ejecución de procesos en 2º plano y de *Core Data* para la gestión y persistencia del modelo de datos.

.
#### Consideraciones adicionales:

- Tras descargarse el JSON remoto, durante su procesamiento en segundo plano para la creación de los NSManagedObjects correspondientes, a veces se produce una excepción no controlada con el mensaje **"collection was mutated while being enumerated"**. Parece que es algún problema con el multiproceso (como si en determinadas ocasiones se estuviera modificando un objeto mientras se ejecuta un fetch). He intentado depurar este bug pero sigue apareciendo ocasionalmente.

- No se ha implementado el formulario de búsqueda en la primera pantalla de la app. He intentado conectar el UISearchController con el CoreDataTableViewController utilizando un NSFetchedResultsController específico para las búsquedas, pero no funcionaba.

- Una vez cargado todo el modelo de datos a partir del Json, cuando se invoca a CoreDataStack.save() antes de cerrar la aplicación (en el método applicationWillTerminate() del appDelegate) los datos se persisten en el fichero SQLite. Sin embargo, cuando en la siguiente ejecución se intenta cargar los datos de este almacén, la tabla con los libros aparece vacía. No se si el fallo se debe a algún problema con el CoreDataStack o con mi implementación, ya que la operación no genera ningún error ni excepción.

- A falta de resolver este problema, se ha comentado la línea que registra en el **UserDefaults** el flag que indica que la aplicación ya se ejecutó una vez. De este modo, en cada nueva ejecución vuelven a descargarse todos los datos del Json (para evitar que la app solo pueda usarse la primera vez).

- Todas las tareas "pesadas" se realizan en segundo plano: descarga del Json remoto, creación de los NSManagedObjects, descarga de PDFs y descarga de las imágenes de portada de los libros.

- Para prevenir problemas de memoria al cargar imágenes -tanto imágenes de portada de libros como imágenes adjuntadas a las notas-, antes de mostrar y de guardar cada imagen en el modelo se redimensionan de forma que en ningún caso excedan las dimensiones de la pantalla, manteniendo la relación de aspecto original (ver **Utils.resizeImage()**).

- Cada anotación está asociada a un libro **y a una página** concretos. Cuando se está visualizando el PDF de un libro, si la página actual tiene una nota asociada, se activará el botón de Ver Nota. En caso contrario, será el botón de Crear Nota el que se active.

- En la colección de notas de un libro, se muestran todas las notas ordenadas por la página a la que corresponden, de menor a mayor.

