# HackerBooks Pro

This is a more complex prototype of ebook reader for iPhone made in Swift 3 and based on the <a href="https://github.com/cdelg4do/HackerBooks">HackerBooks project</a>.

Apart from the functionalities of the previous version, it enables the user to create annotations tied to a specific page of a book. These annotations can store both a text written by the user and an image from the device gallery. Every time the user moves to a page that already has an annotation, the app offers the option to view/edit it. It is possible to visualize a map with the location where the annotation was made.

Also, the user can check all the annotations made on a book through a grid list (sorted by page number) that include their modification date, the page number they belong to, a small portion of the text and, if the annotation has a picture, a thumbnail of it.

This version uses Core Data to manage the model layer objects and their persistence. All heavy operations, like JSON parsing, image & PDF downloads, are performed in background using Grand Central Dispatch (GCD) queues.

&nbsp;
### Screenshots:

<kbd> <img alt="screenshot 1" src="https://cloud.githubusercontent.com/assets/18370149/26028811/08f3a5ec-3828-11e7-8e83-05b080fd29e0.png" width="256"> </kbd> &nbsp; <kbd> <img alt="screenshot 2" src="https://cloud.githubusercontent.com/assets/18370149/26028812/08f4f262-3828-11e7-808a-d6f1fc8ff141.png" width="256"> </kbd> &nbsp; <kbd> <img alt="screenshot 3" src="https://cloud.githubusercontent.com/assets/18370149/26028814/08f8e35e-3828-11e7-835b-89cf79b7e5b5.png" width="256"> </kbd>

&nbsp;
<kbd> <img alt="screenshot 4" src="https://cloud.githubusercontent.com/assets/18370149/26028813/08f7ea30-3828-11e7-8345-5cef98538c63.png" width="256"> </kbd> &nbsp; <kbd> <img alt="screenshot 5" src="https://cloud.githubusercontent.com/assets/18370149/26028816/08ff8664-3828-11e7-8f8b-53cd5e778d7f.png" width="256"> </kbd> &nbsp; <kbd> <img alt="screenshot 6" src="https://cloud.githubusercontent.com/assets/18370149/26028815/08fba738-3828-11e7-8aeb-8b92bb6efffc.png" width="256"> </kbd>
  
&nbsp;
<kbd> <img alt="screenshot 7" src="https://cloud.githubusercontent.com/assets/18370149/26028817/0909e046-3828-11e7-81b6-a6efcfa86851.png" width="256"> </kbd> &nbsp; <kbd> <img alt="screenshot 8" src="https://cloud.githubusercontent.com/assets/18370149/26028818/090c0dda-3828-11e7-9bb9-4f62e280d665.png" width="256"> </kbd> &nbsp; <kbd> <img alt="screenshot 9" src="https://cloud.githubusercontent.com/assets/18370149/26028819/09142a24-3828-11e7-9f76-1c709aba1388.png" width="256"> </kbd>

&nbsp;
#### Additional considerations:

- In order to avoid memory overload when loading images (for both covers or annotations), each image is resized to fit inside the screen dimensions before being stored in the model.

&nbsp;
#### To-Do list:

- Add a UISearchController to the library, in order to filter books by name, authors or tags.

- There is a bug when loading locally stored data from previous executions into the Core Data model (NSInvalidArgumentException: unrecognized selector sent to instance). While this is fixed, the autosave has been diabled, making the app to download again all data on each execution.

