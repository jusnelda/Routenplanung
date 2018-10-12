# Wie lassen sich die folgenden Begriffe (grob) und in Hinblick auf die zu erstellende NaviApp erläutern?

## 1. A* , Dijkstra
* A*: 
    * Im Gegensatz zu uninformierten Suchalgorithmen verwendet der A*-Algorithmus eine Schätzfunktion (Heuristik), um zielgerichtet zu suchen und damit die Laufzeit zu verringern. Der Algorithmus ist vollständig und optimal. Das heißt, dass immer eine optimale Lösung gefunden wird, falls eine existiert. 
    * Berechnung eines kürzesten Pfades zwischen zwei Knoten in einem Graphen mit positiven Kantengewichten.
* Dijkstra: 
    * Er berechnet somit einen kürzesten Pfad zwischen dem gegebenen Startknoten und einem der (oder allen) übrigen Knoten in einem kantengewichteten Graphen (sofern dieser keine Negativkanten enthält). 
	* Für unzusammenhängende ungerichtete Graphen ist der Abstand zu denjenigen Knoten unendlich, zu denen kein Pfad vom Startknoten aus existiert. Dasselbe gilt auch für gerichtete nicht stark zusammenhängende Graphen.  
	
Unterschied: A* verwendet zusätzlich eine Heuristik, dies führt zu einem schnelleren Ergebnis

## 2.  Zusammenhängender Graph
Ein Graph heißt zusammenhängend, wenn die Knoten paarweise durch eine Kantenfolge des Graphen verbunden sind. Ein zusammenhängender Graph: Je zwei Knoten lassen sich durch eine Kantenfolge verbinden.

## 3. (ESRI) World File
Ein World-File ist eine kleine Textdatei, die Georeferenzdaten eines Bildes enthält. Dieser Filialdateityp wurde vom Unternehmen ESRI als Ergänzung für einfache Bildformate eingeführt. Die Dateinamenserweiterung leitet sich vom Bildtyp ab und lautet beispielsweise .jgw, .j2w, .pgw, .gfw oder .tfw für JPEG-, JPEG 2000-, PNG-, GIF- oder TIFF-Bilddaten. Das Bezugssystem fehlt in der Datei. 
    
## 4. Georeferenzieren
Zuweisung raumbezogener Informationen, der Georeferenz, zu einem Datensatz. 
 
## 5. Laplace Matrix, Satz von Fiedler
Die Laplace-Matrix ist in der Graphentheorie eine Matrix, welche die Beziehungen der Knoten und Kanten eines Graphen beschreibt.
    
## 6. k-d-Tree
In computer science, a k-d tree (short for k-dimensional tree) is a space-partitioning data structure for organizing points in a k-dimensional space. k-d trees are a useful data structure for several applications, such as searches involving a multidimensional search key (e.g. range searches and nearest neighbor searches).
(Welcher Knoten liegt am nächsten zu meiner aktuellen GPS-Position)
    
## 7. Kachelung einer Karte
Hochaufgelöste Rastergrafiken werden mit Hilfe von Geodiensten in Kacheln zerteilt und die jeweils benötigten Teile des Gesamtbildes übertragen und angezeigt. Web Map Tile Service ist ein Standard des Open Geospatial Consortium für Kartenkachel-Server. 
    
## 8. Ameisenalgorithmus
Mit Ameisenalgorithmen lassen sich vor allem kombinatorische Optimierungsprobleme lösen, beispielsweise Projektplanungsprobleme oder das Quadratische Zuordnungsproblem, IP-Routing oder Probleme der Logistik (traveling salesman problem). 
Da es sich um heuristische Optimierungsverfahren handelt, kann nicht garantiert werden, dass immer die optimale Lösung gefunden wird. Deshalb ist ein Einsatz auch nur dann sinnvoll, wenn eine optimale Lösung nicht unbedingt gefunden werden muss oder nicht in akzeptabler Rechenzeit gefunden werden kann. 
	
## 9. Adjazenzmatrix  /  Adjazenzliste
Eine Adjazenzmatrix (manchmal auch Nachbarschaftsmatrix) eines Graphen ist eine Matrix, die speichert, welche Knoten des Graphen durch eine Kante verbunden sind. Sie besitzt für jeden Knoten eine Zeile und eine Spalte, woraus sich für n Knoten eine n x n-Matrix ergibt. Ein Eintrag in der i-ten Zeile und j-ten Spalte gibt hierbei an, ob eine Kante von dem i-ten zu dem j-ten Knoten führt. Steht an dieser Stelle eine 0, ist keine Kante vorhanden – eine 1 gibt an, dass eine Kante existiert, siehe Abbildung rechts. 

## 10. Shapefile
Das Dateiformat Shapefile (oft Shapedaten oder Shape genannt) ist ein ursprünglich für die Software ArcView der Firma ESRI entwickeltes Format für Geodaten. Zum Abspeichern von Straßensegmenten und Knoten.

## 11. Map Matching 
Mit Kartenabgleich, Karteneinpassung oder auch englisch Map Matching wird ein Verfahren bezeichnet, welches die durch eine Ortung gemessene Position eines Objektes mit den Ortsinformationen einer digitalen Karte abgleicht. 

# Mapping Toolbox 
_(nicht im Skript)_

## 1. Wie lassen sich die einzelnen Schritte aus Aufgabe 1. Woche Aufgabe (von projizierten NAD83 Koordinaten zu geographischen Koordinaten) stichpunktartig erläutern?

## 2. Wie lassen sich folgende Funktionen und Methoden erläutern?
* `unitsratio` = Berechnet Skalierungsfaktor
    _The unitsratio function makes it easy to convert values from one system of units to another. For example, if you want to convert the value 100 kilometers (from units) to meters (to units), you can use the following code:_

    ```matlab
    y = unitsratio('meters','kilometers') * 100
    y =

          100000
    ```
* `mapshow` = Darstellen projizierter Information (z.B. ein in NAT83 projiziertes Shapefile)
    _Displays the coordinate vectors x and y as lines. You can optionally display the coordinate vectors as points or polygons by using the DisplayType name-value pair argument._
* `geoshow(lat,lon)` = Darstellen von geographischer Information (Karte, Shapefile)
    _Projects and displays the latitude and longitude vectors lat and lon using the projection stored in the current axes. If there is no projection, lat and lon are projected using a default Plate Carrée projection.
    By default, geoshow displays lat and lon as lines. You can optionally display the vector data as points, multipoints, or polygons by using the DisplayType name-value pair argument._
* `[lat,lon] = projinv(proj,x,y)` = Berechnet die inverse Projektion
    _Returns the latitude and longitude values from the inverse projection transformation. proj is a structure defining the map projection. proj can be a map projection mstruct or a GeoTIFF info structure. x and y are x-y map coordinate arrays. For a complete list of GeoTIFF info and map projection structures that you can use with projinv, see the reference page for projlist._
* `info = geotiffinfo(filename)` = Übergabeparameter ist ein Geotiff, Geotifinfo extrahiert die Projektionsparameter aus der Header des Geotifs
    _Returns a structure whose fields contain image properties and cartographic information about a GeoTIFF file._
* Shaperead
    ```matlab
    S = shaperead('concord_roads.shp','Selector',... {@(v1,v2) (v1 >= 4) && (v2 >= 200),'CLASS','LENGTH'} )
    ```
    Aus dem Shapefile 'concord_roads.shp' werden alle Straßenklassen >= 4 und alle Straßensegmente mit Länge >= 200 [meter] extrahiert.
    _Read road data only for class 4 and higher road segments that are at least 200 meters in length. Note the use of an anonymous function in the selector._

## 3. Was steht in dem Shapefile boston_roads.shp in den Feldern X und Y? 
In den Feldern X und Y stehen die sog. Formparameter, also die gemessenen Koordinaten. 